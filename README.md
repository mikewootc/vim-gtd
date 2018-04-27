# vim-gtd

vim plugin which is designed by the concept of gtd.

## Overview

Overview:

![overview](./test/overview.png)


## Features

* Manage projects(subprojects) and task.
* Add planned (due) date and finished date(default today) by keyboard shortcuts, and can be seleted from calendar.
* Color highlight for planned / emergency / overdued TODOs.
* Specify workers by @Somebody mark.
* Specify context by #Somewhere# mark
* Support priorities for TODOs.
* Support repeated tasks / daily tasks.



## Usage

The easiest way to get started is playing around with the example file gtd/test/t.gtdt. And with key mapping:

    <leader>gp : Add gtd plan date.
    <leader>gf : Finish task(or project).
    <leader>gt : Show the planned tasks in a splited window, with emergency and overdued task included.
    <leader>gc : Reset daily task, such as: <d1:v><d2:v><d3:-><d4:-><d5:-><d6:-><d7:-> Get up early. [t:2018-04-04]
    <tab>      : Switch folding status(between zO and zC).

The more handy short cut:

    <leader>p : Add gtd plan date.
    tt        : Toggle task list.
    ff        : Finish task.
    fx        : Fail daily task.
    <leader>c : Reset daily task, such as: <d1:v><d2:v><d3:-><d4:-><d5:-><d6:-><d7:-> Get up early. [t:2018-04-04]

## Syntax

    Title:                  [[ThisIsTitle]]
    High priority project:  [*] This is a high priority project
    Low priority project:   [.] This is a low priority project

    Normal task:            * task here
    Daily task:             * <d1:v><d2:v><d3:-><d4:-><d5:-><d6:-><d7:-> Get up early.
                                // <d2:v> means finished, <d3:x> means failed, <d4:->means next todo(tomorrow).

    Date(planned):          [p:2018-05-02]
    Date(emergency):        [e:2018-05-02]
    Date(today):            [t:2018-05-02]
    Date(overdued):         [o:2018-05-02]
    Date(finished):         [f:2018-05-02]

    Context:                #Home#
    Worker:                 @Mike
    Should not task:        <shnot> This the task I actually did but should not do according to plan.

    Bold:                   **Bold**
    Note:                   > Note here
    Comment:                // Comment here
    Separator line:         Work ================================================
    Fold:                   Folded {{{
                                  Folded.
                                  Folded2.
                            }}}

## Config

In vimrc, set:

    let g:gtd_gtdfiles = ["~/my.gtd", "~/my2.gtd"]
        Set the gtd file list so you can open them all by command :Gtdo
        default: ["~/.my_vimgtd.gtd"]
    let g:gtd_auto_check_overdue = 0
        If set to 1, then the plugin will check if task overdue automatically
        when opening gtd file.
        default: 0
    let g:gtd_check_overdue_auto_save = 0
        If set to 1, then gtd file will automatically be saved after check-overdue.
        default: 0
    let g:task_list_with_parents = 1
        If set to 1, then task list would show with its parents.
        If set to 0, then task list would only show the task itself.
        default: 1
    let g:gtd_emergency_days = 7
        Set the days that would considered as emergency if the interval
        from today to the planned date is less than this value.
        default: 7

