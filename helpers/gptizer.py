"""
A script to generate n files of length ContextLength/n for an LLM so that you can send your whole project in the least
number of messages.

Script Usage:

    python script_name.py --dir /path/to/your/codebase --context-length 24000

Description:

    This script processes and annotates source code files in the specified directory, splitting them into chunks based on a maximum token limit suitable for processing by language models. It supports a variety of popular programming languages, as specified in the `SUPPORTED_EXTENSIONS` list.

Arguments:

    --dir, -d            Required. The directory containing the source code files to process.
    --context-length, -c Optional. The maximum number of tokens per output file. Default is 4096.

Example:

    python script_name.py --dir ./my_project --context-length 8000

Output:

    The script generates output files in the `gptizer_op` directory within the specified codebase directory.
    Each output file contains annotated content, along with predefined messages indicating the part number 
    and, if applicable, the first or last message.

Notes:

    - Ensure that the `tree` command is installed and accessible. If it's located elsewhere, update the path in the `get_directory_tree` function.
    - The `SUPPORTED_EXTENSIONS` list can be modified to include additional file types.
    - The script ignores certain directories like `node_modules`, `dist`, `build`, `.venv`, and `gptizer_op` during processing.
"""


import argparse
import shutil
import subprocess
from pathlib import Path
from typing import List

try:
    import tiktoken
except ImportError:
    raise ModuleNotFoundError(
        "tiktoken is not installed, make sure you installed the requirements.txt"
    )

# Load OpenAI’s tokenizer to handle text as tokens
ENCODER = tiktoken.get_encoding("cl100k_base")

# Supported file extensions
SUPPORTED_EXTENSIONS = [
    ".js",
    ".ts",
    ".tsx",
    ".jsx",
    ".py",
    ".json",
    ".env",
    ".go",
    ".java",
    ".rb",
    ".php",
    ".c",
    ".cpp",
    ".cs",
    ".swift",
    ".kt",
    ".m",
    ".scala",
    ".rs",
    ".sh",
    ".bat",
    ".pl",
    ".ps1",
    ".erl",
    ".exs",
    ".r",
    ".sql",
    ".md",
    ".txt",
    ".c",
    ".cpp",
]

FIRST_MESSAGE_PROMPT = "I will send you my codebase, and this is the first part"
NEXT_MESSAGE_PROMPT = "This is the {index}th part"
LAST_MESSAGE_PROMPT = "This is the last message"
OUTPUT_PATH = Path("gptizer_op")

IGNORED_DIRS = [
    "node_modules", "dist", "build", str(OUTPUT_PATH), ".venv", "venv", ".git", "^.", Path(__file__).name,
]

def parse_arguments():
    """
    Parse command-line arguments to get the directory path and context length.

    Returns:
        argparse.Namespace: The parsed arguments containing the directory path and context length.
    """
    parser = argparse.ArgumentParser(
        description="Process and annotate source code files."
    )
    parser.add_argument(
        "--dir", "-d", required=True, type=str, help="Directory to search for files"
    )
    parser.add_argument(
        "--context-length",
        "-c",
        type=int,
        default=4096,
        help="Maximum tokens per output file",
    )
    return parser.parse_args()


def get_supported_files(directory: Path, ignore_dirs: List[str] = None) -> List[Path]:
    """
    Get all files with supported extensions in the specified directory,
    ignoring specified subdirectories.

    Args:
        directory (Path): The directory to search.
        ignore_dirs (List[str]): List of directory names to ignore during the search.

    Returns:
        List[Path]: A list of file paths matching the supported extensions.
    """
    ignore_dirs = ignore_dirs or IGNORED_DIRS
    supported_files = []
    for path in directory.rglob("*"):
        # Skip ignored directories
        if any(ignored in path.parts for ignored in ignore_dirs):
            continue
        if path.suffix in SUPPORTED_EXTENSIONS:
            supported_files.append(path)
    return supported_files


def annotate_file_content(file_path: Path, base_dir: Path, comment_prefix="//") -> str:
    """
    Annotate the content of a file by adding its relative path as a comment.

    Args:
        file_path (Path): The file path to read and annotate.
        base_dir (Path): The base directory to calculate the relative path.
        comment_prefix (str): Prefix for comment, for supporting multiple languages.

    Returns:
        str: Annotated content of the file with relative path and original content.
    """
    relative_path = file_path.relative_to(base_dir)
    with file_path.open("r", encoding="utf-8") as file:
        content = file.read()

    # Remove /Users/<current_user> for privacy
    base_dir = Path(*base_dir.parts[3:])
    full_path = base_dir / relative_path

    return f"{comment_prefix} {full_path}\n\n{content}\n"


def tokenize_content(content: str) -> int:
    """
    Count tokens in a given content string using tiktoken.

    Args:
        content (str): The content to tokenize.

    Returns:
        int: The token count of the content.
    """
    return len(ENCODER.encode(content,  disallowed_special=()))


def write_to_output_file(output_content: List[str], output_file: Path, append=False):
    """
    Write content to an output file.

    Args:
        output_content (List[str]): List of file contents to write.
        output_file (Path): Path of the output file.
        append (bool): Append or overwrite the file.
    """
    with output_file.open("w" if not append else "a", encoding="utf-8") as output:
        output.write("\n".join(output_content))


def collect_annotated_contents(files: List[Path], base_dir: Path) -> List[str]:
    """
    Collect and annotate contents from a list of files.

    Args:
        files (List[Path]): List of file paths to annotate.
        base_dir (Path): The base directory to calculate relative paths.

    Returns:
        List[str]: List of annotated file contents.
    """
    annotated_contents = []
    for file in files:
        annotated_content = annotate_file_content(file, base_dir)
        annotated_contents.append(annotated_content)
    return annotated_contents


def split_contents_by_token_limit(
    contents: List[str], max_tokens: int
) -> List[List[str]]:
    """
    Split contents into chunks where each chunk's token count does not exceed max_tokens.

    Args:
        contents (List[str]): List of annotated file contents.
        max_tokens (int): Maximum tokens allowed per chunk.

    Returns:
        List[List[str]]: List of chunks, each chunk is a list of contents.
    """
    chunks = []
    current_chunk = []
    current_token_count = 0

    for content in contents:
        content_tokens = tokenize_content(content)
        if current_token_count + content_tokens > max_tokens and current_chunk:
            # Start a new chunk
            chunks.append(current_chunk)
            current_chunk = []
            current_token_count = 0
        current_chunk.append(content)
        current_token_count += content_tokens

    if current_chunk:
        chunks.append(current_chunk)

    return chunks


def get_directory_tree(base_dir: Path) -> str:
    """
    Get the directory tree as a string.

    Args:
        base_dir (Path): The base directory.

    Returns:
        str: Directory tree output.
    """
    handler_exec = ['tree']

    if not shutil.which(handler_exec[0]):
        handler_exec = ['ls', '-T']

    p = subprocess.run(
        [
            *handler_exec,
            str(base_dir),
            "-I",
            f".venv|node_modules|dist|build|{str(OUTPUT_PATH)}",
        ],
        stdout=subprocess.PIPE,
        stderr=subprocess.PIPE,
    )
    return p.stdout.decode()


def add_messages_to_chunks(chunks: List[List[str]], base_dir: Path) -> List[str]:
    """
    Add predefined messages to each chunk as specified.

    Args:
        chunks (List[List[str]]): List of content chunks.
        base_dir (Path): The base directory to get the directory tree.

    Returns:
        List[str]: List of final contents for each chunk.
    """
    total_parts = len(chunks)
    final_chunks = []

    for index, chunk in enumerate(chunks):
        chunk_content = []

        # Add predefined messages as required
        if total_parts > 1:
            if index == 0:
                # First chunk
                chunk_content.append(FIRST_MESSAGE_PROMPT)
            elif index == total_parts - 1:
                # Last chunk
                chunk_content.append(LAST_MESSAGE_PROMPT)
            else:
                # Middle chunks
                chunk_content.append(NEXT_MESSAGE_PROMPT.format(index=index + 1))

        # For the first chunk, add directory tree
        if index == 0:
            dir_tree = get_directory_tree(base_dir)
            chunk_content.append(dir_tree)

        # Add the content
        chunk_content.extend(chunk)
        final_chunks.append("\n".join(chunk_content))

    return final_chunks


def write_chunks_to_files(chunks: List[str], output_base_name: Path):
    """
    Write each chunk to an output file.

    Args:
        chunks (List[str]): List of contents for each chunk.
        output_base_name (Path): Base name for output files.
    """
    for index, content in enumerate(chunks):
        output_file = Path(f"{output_base_name}_{index + 1}.txt")
        write_to_output_file([content], output_file)
        token_count = tokenize_content(content)
        print(f"created {output_file} with {token_count} tokens.")


def compile_contents_to_text(
    files: List[Path], base_dir: Path, output_base_name: Path, max_tokens: int
):
    """
    Compile all annotated file contents into text files, splitting if token count exceeds max_tokens.

    Args:
        files (List[Path]): List of file paths to annotate and compile.
        base_dir (Path): The base directory to calculate relative paths.
        output_base_name (Path): Base name for output files.
        max_tokens (int): Maximum tokens per output file.
    """
    # Collect annotated contents
    annotated_contents = collect_annotated_contents(files, base_dir)

    # Split contents into chunks based on token limit
    content_chunks = split_contents_by_token_limit(annotated_contents, max_tokens)

    # Add predefined messages to chunks
    final_chunks = add_messages_to_chunks(content_chunks, base_dir)

    # Write chunks to output files
    write_chunks_to_files(final_chunks, output_base_name)


def main():
    """
    Main function to execute the script. Parses arguments, processes files,
    and generates the compiled text files.
    """
    args = parse_arguments()
    base_dir = Path(args.dir).resolve()
    output_base_name = base_dir / OUTPUT_PATH
    output_base_name.mkdir(exist_ok=True)
    output_base_name = output_base_name / "op"

    max_tokens = args.context_length

    supported_files = get_supported_files(base_dir)
    if not supported_files:
        print("No files with supported extensions found in the specified directory.")
        return

    compile_contents_to_text(supported_files, base_dir, output_base_name, max_tokens)


if __name__ == "__main__":
    main()
