# Shell fails to load on MacOS

This means that I have added some terminal-stuff to files like .zshrc. Those files should have shell related stuff and not terminal related, but I did mistakenly add some UI options, some keymapping and more there. Which fail when running on a shell 
that has no terminal like pycharm shell (since pycharm spawns its own shell on MacOS).

The solution is to wrap the terminal-specific stuff in the following block

```bash
if [ -z "$INTELLIJ_ENVIRONMENT_READER" ]; then
    # terminal environment code
fi
```
