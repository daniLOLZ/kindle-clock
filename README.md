# Kindle Clock

This turns a Kindle Paperwhite into a pretty clock 
Forked from mattzzw/kindle-clock and modified it to also hold my tasks from Todoist instead of the weather info

Modifications from the original:
* Removed weather info
* Added Todoist integration to fetch tasks with the label `KINDLE`
* Made a checkerboard like pattern for the tasks
* Shows a nice image at the top of the screen :)
* Refactored some code
* Reduced number of wakes during the night, from `NIGHT_START` to `NIGHT_END`

These settings are specifically finetuned for my kindle so you might have to tweak some numbers for it to display properly

## What's what
* `kindle-clock.sh`: Main loop, displays clock and tasks, suspend to RAM and wakeup
* `config.xml`: KUAL config file
* `menu.json`: KUAL config file
* `get_tasks.py`: Utility to parse the tasks since json is hard in sh

The script logs to `./clock.log`.

## Installation:
* create directory `/mnt/us/extensions/clock` (you can choose another name for this last directory as long as it's in `/mnt/us/extensions/`
* copy everything to the newly created directory 
* create the file `api_key.txt` containing your Todoist API key. You can find it in Settings > Integrations > Developer > API key

## Starting Clock
* Open up KUAL and press 'Clock - Todoist'

## Stopping :
* Force reboot kindle by holding powerbutton until it resets

## Todo list (heh):
* [x] Parametrize the grid
* [ ] Add a showcase image
* [ ] Find more useless processes to stop 
* [ ] Find a way to more efficiently parse the tasks and maybe not rely on a python script
* [ ] Estimate the power consumption of different parts of the script
    * [ ] Normal use
    * [ ] Without enabling wifi to update time and tasks
    * [ ] Without refreshing the screen and redrawing the tasks
    * [ ] Without any of the above (night mode)
