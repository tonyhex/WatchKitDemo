//
//  InterfaceController.m
//  WatchKitDemo WatchKit Extension
//
//  Created by Anton Serov on 07/05/15.
//  Copyright (c) 2015 Rambler. All rights reserved.
//

#import "InterfaceController.h"
#import "ItemListRowController.h"

@interface InterfaceController()
@property (nonatomic, weak) IBOutlet WKInterfaceTable *table;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSArray *list;
@end


@implementation InterfaceController

- (NSUserDefaults *)defaults {
    if (_defaults == nil) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rambler.demo.shared"];
    }
    
    return _defaults;
}

- (void)awakeWithContext:(id)context {
    [super awakeWithContext:context];
    
    [self loadList];
}

- (void)loadList {
    [self.defaults synchronize];
    self.list = [self.defaults objectForKey:@"list"];
    [self updateListView];
}

- (void)updateListView {
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

- (void)willActivate {
    [super willActivate];
}

- (void)didDeactivate {
    [super didDeactivate];
}

- (IBAction)refresh:(id)sender {
    [self loadList];
}

@end



