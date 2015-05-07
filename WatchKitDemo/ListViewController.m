//
//  ViewController.m
//  WatchKitDemo
//
//  Created by Anton Serov on 07/05/15.
//  Copyright (c) 2015 Rambler. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()

@property (nonatomic, weak) IBOutlet UIBarButtonItem *addBarButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *removeBarButton;
@property (nonatomic, strong) NSUserDefaults *defaults;
@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ListViewController

- (NSUserDefaults *)defaults {
    if (_defaults == nil) {
        _defaults = [[NSUserDefaults alloc] initWithSuiteName:@"group.com.rambler.demo.shared"];
    }
    
    return _defaults;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.list = [self.defaults objectForKey:@"list"] ? : [@[] mutableCopy];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)add:(id)sender {
    [self addListItem:[@"Item #" stringByAppendingString:@(self.list.count + 1).stringValue]];
}

- (IBAction)remove:(id)sender {
    [self removeLastListItem];
}

#pragma mark Table delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ListItemCellId"];
    cell.textLabel.text = self.list[indexPath.row];
    return cell;
}

#pragma mark List actions

- (void)addListItem:(id)listItem {
    [self.list addObject:listItem];
    [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.list.count - 1 inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.defaults setObject:self.list forKey:@"list"];
    [self.defaults synchronize];
}

- (void)removeLastListItem {
    if (self.list.count == 0) {
        return;
    }
    [self.list removeLastObject];
    [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.list.count inSection:0]]
                          withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.defaults setObject:self.list forKey:@"list"];
    [self.defaults synchronize];
}

@end
