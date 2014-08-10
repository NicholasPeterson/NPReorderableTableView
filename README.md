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

- Installation -
--

Clone the git repo:
```sh
git clone https://github.com/NicholasPeterson/NPReorderableTableView.git NPReorderableTableView

```

Copy the `NPReorderableTableView.h` and `NPReorderableTableView.m` into your project.

- Basic Usage-
--
**1: Instantiate and make visible**

Init and add the NPReorderableTableView as you would a regular UITableView. You may also use this class in Interface Builder.
```objective-c
- (void)setupTableView {
        self.tableView = [[NPReorderableTableView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:self.tableView];
        self.tableView.dataSource = self;
}
```

**2: Register your cell and a placeholder cell**

_Note: You need to register a "Placeholder Cell". We will use it in the next step._
```objective-c
 [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Placeholder"];

[self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"MyCell"];
```

**3: Change `tableView:cellForRowAtIndexPath:`**

```objective-c
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;

    if (self.tableView.dragging && [indexPath isEqual:self.tableView.dropIndexPath]) {
         // The user is reordering the table. 
        cell = [tableView dequeueReusableCellWithIdentifier:@"Placeholder"];
        
        // Configure your placeholder cell.
        cell.contentView.backgroundColor = [UIColor lightGrayColor];
    } else {
        cell = [tableView dequeueReusableCellWithIdentifier:@"MyCell"];
        //Create your normal cell.
    }

    return cell;
}
```

**4: Commit the drop** 

Commit the changes when the user completes the reorder.
```objective-c
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath {
    // Commit your changes to your datasource. For example:
    id buffer = self.data[sourceIndexPath.row];
    [self.testData removeObjectAtIndex:sourceIndexPath.row];
    [self.testData insertObject:buffer atIndex:destinationIndexPath.row];
}

```

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
