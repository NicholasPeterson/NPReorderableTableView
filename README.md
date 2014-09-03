NPReorderableTableView
=========

Replacement for Apples UITableView providing drag-and-drop reordering with no drag handles. 

**This is a very early prototype and I havent squashed all the bugs yet. Use in a production app at your own risk!**

[![](https://s3-us-west-1.amazonaws.com/nicholas-peterson-github/fast_demo.gif)](https://s3-us-west-1.amazonaws.com/nicholas-peterson-github/fast_demo.gif)

The Story
-----------
> On 3 seperate occassions I have found the need for a reorderable table view and in each case Apples drag handle UI was not part of the design. So, on 3 seperate occassions I have needed to implement my own.

> NPReorderableTableView is intended to be a drop in replacement for UITableView and be able to fit into most iOS designs. 

Requirements
----
- iOS7 +
- UIKit Framework

Getting Started
--------------
**_CocoaPod support coming soon_**

NPReorderableTableView is intended to be used like a regular UITableView with as few exceptions as possible.
**Read the [QuickStartViewController](https://github.com/NicholasPeterson/NPReorderableTableView/blob/master/NPReorderableTableView/QuickStartViewController.m) to get started.**

- Advanced Usage -
--
**Turning off Reordering**

Turning off the reordering is as easy as setting `allowsDragging = NO;`

If a drag was already in progress the cell will be dropped immediately.

**Hide invalid move animation**

By default when the user drags the cell to an invalid location the cell will tilt to indicate a state change to the user. 

To allow more design flexability you can hide the associated animation by setting `showsInvalidMove = NO;`


Contribution
----

**Contribution welcome.** If you squash a bug submit a pull request and share with others.

License
----

MIT

**Use how you like!**
