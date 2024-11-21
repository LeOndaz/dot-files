setopt PROMPT_SUBST

function color_path() {
   local path_string="$(print -P '%~')"
   local path_components=(${(s:/:)path_string})
   local path_length=${#path_components}

   if (( path_length > 3 )); then
       echo "%F{031}.../${(j:/:)path_components[-3,-2]}/%F{045}${path_components[-1]}%f"
   elif (( path_length > 1 )); then
       echo "%F{031}${(j:/:)path_components[1,-2]}/%F{045}${path_components[-1]}%f"
   else
       echo "%F{045}${path_components[1]}%f"
   fi
}

PROMPT='$(color_path) \$ '