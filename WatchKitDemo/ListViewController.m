//
//  ViewController.m
//  WatchKitDemo
//
//  Created by Anton Serov on 07/05/15.
//  Copyright (c) 2015 Rambler. All rights reserved.
//

#import "ListViewController.h"

@interface ListViewController ()<NSFilePresenter>

@property (nonatomic, weak) IBOutlet UIBarButtonItem *addBarButton;
@property (nonatomic, weak) IBOutlet UIBarButtonItem *removeBarButton;
@property (nonatomic, strong) NSFileCoordinator *fileCoordinator;
@property (nonatomic, strong) NSMutableArray *list;

@end

@implementation ListViewController

- (NSFileCoordinator *)fileCoordinator {
    if (_fileCoordinator == nil) {
        _fileCoordinator = [[NSFileCoordinator alloc] init];
    }
    
    return _fileCoordinator;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.fileCoordinator
     coordinateReadingItemAtURL:[self presentedItemURL]
     options:NSFileCoordinatorReadingWithoutChanges
     error:nil
     byAccessor:^(NSURL *newURL) {
         NSData *data = [NSData dataWithContentsOfURL:newURL];
         id object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
         self.list = object != nil ? [NSMutableArray arrayWithArray:object] : [@[] mutableCopy];
         [self.tableView reloadData];
    }];
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

- (void)saveListWithCompletion:(void (^)(void))completion {
    [self.fileCoordinator
     coordinateWritingItemAtURL:[self presentedItemURL]
     options:NSFileCoordinatorWritingForReplacing
     error:nil
     byAccessor:^(NSURL *newURL) {
         NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self.list];
         [data writeToURL:newURL atomically:YES];
         if (completion != nil) {
             completion();
         }
    }];
}

- (void)addListItem:(id)listItem {
    [self.list addObject:listItem];
    [self saveListWithCompletion:^{
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.list.count - 1 inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
}

- (void)removeLastListItem {
    if (self.list.count == 0) {
        return;
    }
    [self.list removeLastObject];
    [self saveListWithCompletion:^{
        [self.tableView deleteRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:self.list.count inSection:0]]
                              withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
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

@end
