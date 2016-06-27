Github Commands
===================

Basic commit and push
----------------------

`git status` = always a good idea to give you an idea of where you are
`git add [filename]` = add the file(s) you want to commit
`git commit -m "[message]"` = commit the files to be pushed
`git push` = push them up to the remote branch

Checkout remote branch
-----------------------

`git fetch origin` = get all branches (including remote)
`git branch -v -a` = look at list of all available branches
`git checkout -b [name you want locally] [remote name]` = checkout the remote branch on your local machine

Switching branches
-----------------------

`git checkout [branch name]`

Development branching
-----------------------

`git checkout -b [new branch name]` = make a new branch
[basic commit and push] = follow above steps for making changes
go back to `master` branch 
`git merge [branch name] = merge your development branch into master branch
`git branch -d [branch name] = delete local branch that is no longer needed
`git push origin --delete [branch name] = delete remote version of that branch