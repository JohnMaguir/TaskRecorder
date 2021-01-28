# TaskRecorder
Small ruby script to record my daily tasks and compile my weekly notes

To Run
```
ruby task-recorder.rb {command}
```

Available Commands:
```
done: "Add task to done for today",
todo: "Add task to todo for tomorrow",
notes: "Compile notes of completed tasks for the week incl. prior Friday as weekly meeting is Friday morning",
standup: "Output notes to be pasted in dev-standup this morning",
today: "Output notes for today",
clean: "Remove files from all weeks but current one and prior Friday",
help: "Display help notes for commands"
```
`done` and `todo` commands require a second param that is a description of the task, use Quotation marks to ensure this is taken as one string

e.g.
```
ruby task-recorder.rb done "Long task that I did today"
```
or
```
ruby task-recorder.rb done "Long task that I will do tomorrow"
```
This will generate a task file for today like:
```
*Yesterday*
>Long task that I did today
*Today*
>Long task that I will do tomorrow
```
At the end of the week you can run:
```
ruby task-recorder.rb notes
```
It will compile list of all tasks under the Yesterday header and compile them into a list of completed tasks for the week.

At the strat of each day you can run
```
ruby task-recorder.rb standup
```
To see a list fo the tasks you finished yesterday and have scheduled to complete today

At any point during the day you can run
```
ruby task-recorder.rb today
```
To see a list of the tasks you have completed today and what you have planned for tomorrow.


Recommend adding this script as alias in bashrc so that you have easy access throughout console
example bashrc entry
```
alias tr='ruby /path/to/repo/TaskRecorder/task-recorder.rb'
```
Then you can simply run
````
tr {command}
```
