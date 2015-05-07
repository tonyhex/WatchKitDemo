//
//  InterfaceController.m
//  WatchKitDemo WatchKit Extension
//
//  Created by Anton Serov on 07/05/15.
//  Copyright (c) 2015 Rambler. All rights reserved.
//

#import "InterfaceController.h"
#import "ItemListRowController.h"

@interface InterfaceController()<NSFilePresenter>
@property (nonatomic, weak) IBOutlet WKInterfaceTable *table;
@property (nonatomic, strong) NSFileCoordinator *fileCoordinator;
@property (nonatomic, strong) NSArray *list;
@end


@implementation InterfaceController

- (NSFileCoordinator *)fileCoordinator {
    if (_fileCoordinator == nil) {
        _fileCoordinator = [[NSFileCoordinator alloc] init];
    }
    
    return _fileCoordinator;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    [NSFileCoordinator addFilePresenter:self];
}

- (void)loadList {
    [self.fileCoordinator
     coordinateReadingItemAtURL:[self presentedItemURL]
     options:NSFileCoordinatorReadingWithoutChanges
     error:nil
     byAccessor:^(NSURL *newURL) {
         NSData *data = [NSData dataWithContentsOfURL:newURL];
         id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         self.list = object != nil ? [NSMutableArray arrayWithArray:object] : [@[] mutableCopy];
         [self populateListView];
     }];
}

- (void)populateListView {
    if (self.table.numberOfRows) {
        [self.table removeRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.table.numberOfRows)]];
    }
    if (self.list.count > 0) {
        [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, self.list.count)]
                            withRowType:@"ItemListRowControllerId"];
        NSUInteger idx = 0;
        for (id item in self.list) {
            ItemListRowController *rowController = [self.table rowControllerAtIndex:idx++];
            [rowController.label setText:item];
        }
    }
}

- (void)updateListView:(NSArray *)newList {
    NSIndexSet *newItemsIndexSet = [newList indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ![self.list containsObject:obj];
    }];
    NSIndexSet *removedItemsIndexSet = [self.list indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        return ![newList containsObject:obj];
    }];
    
    [self.table removeRowsAtIndexes:removedItemsIndexSet];
    
    for (id newItem in [newList objectsAtIndexes:newItemsIndexSet]) {
        [self.table insertRowsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(self.table.numberOfRows, 1)]
                            withRowType:@"ItemListRowControllerId"];
        ItemListRowController *rowController = [self.table rowControllerAtIndex:self.table.numberOfRows - 1];
        [rowController.label setText:newItem];
    }
}

- (void)willActivate {
    [super willActivate];
    [self loadList];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (IBAction)refresh:(id)sender {
    [self loadList];
}

#pragma mark NSFilePresenter impl

- (NSURL *)presentedItemURL {
    NSURL *containerURL =
    [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:@"group.com.rambler.demo.shared"];
    return [containerURL URLByAppendingPathComponent:@"list"];
}

- (NSOperationQueue *)presentedItemOperationQueue {
    return [NSOperationQueue mainQueue];
}

- (void)presentedItemDidChange {
    [self.fileCoordinator
     coordinateReadingItemAtURL:[self presentedItemURL]
     options:NSFileCoordinatorReadingWithoutChanges
     error:nil
     byAccessor:^(NSURL *newURL) {
         NSData *data = [NSData dataWithContentsOfURL:newURL];
         id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         NSArray *newItems = [NSMutableArray arrayWithArray:object];
         [self updateListView:newItems];
         self.list = newItems;
     }];
}

@end



