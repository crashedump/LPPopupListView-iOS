//
//  LPMainViewController.m
//  LPPopupListViewExample
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

#import "LPMainViewController.h"
#import "LPListViewModel.h"


@interface LPMainViewController ()

@property (nonatomic, strong) NSMutableIndexSet *selectedIndexes;

@end


@implementation LPMainViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSDictionary *info = [[NSBundle mainBundle] infoDictionary];
    NSString *bundleName = [NSString stringWithFormat:@"%@", [info objectForKey:@"CFBundleDisplayName"]];
    self.title = bundleName;
}

#pragma mark - Button

- (IBAction)onReactiveButtonClicked:(id)sender {
    float paddingTopBottom = 20.0f;
    float paddingLeftRight = 20.0f;
    
    CGPoint point = CGPointMake(paddingLeftRight, (self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + paddingTopBottom);
    CGSize size = CGSizeMake((self.view.frame.size.width - (paddingLeftRight * 2)), self.view.frame.size.height - ((self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + (paddingTopBottom * 2)));
    
    LPListViewModel *vm = [[LPListViewModel alloc] initWithTitle:@"Reactive"];
    LPPopupListView *listView = [[LPPopupListView alloc] initWithViewModel:vm point:point size:size disableBackgroundInteraction:YES enableFilterBar:YES];
    [listView showInView:self.navigationController.view animated:YES];
}

- (IBAction)buttonClicked:(id)selector
{
    float paddingTopBottom = 20.0f;
    float paddingLeftRight = 20.0f;
    
    CGPoint point = CGPointMake(paddingLeftRight, (self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + paddingTopBottom);
    CGSize size = CGSizeMake((self.view.frame.size.width - (paddingLeftRight * 2)), self.view.frame.size.height - ((self.navigationController.navigationBar.frame.size.height + paddingTopBottom) + (paddingTopBottom * 2)));
    
    LPPopupListView *listView = [[LPPopupListView alloc] initWithTitle:@"List View" list:[self list] selectedIndexes:self.selectedIndexes point:point size:size multipleSelection:YES disableBackgroundInteraction:YES];
    listView.delegate = self;
    listView.titleLabel.text = @"Select";
    [listView.cancelButton setTitle:@"Отменить" forState:UIControlStateNormal];
    [listView showInView:self.navigationController.view animated:YES];
}

#pragma mark - LPPopupListViewDelegate

- (void)popupListView:(LPPopupListView *)popUpListView didSelectIndex:(NSInteger)index
{
    NSLog(@"popUpListView - didSelectIndex: %ld", (long)index);
    self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndex:index];
}

- (void)popupListViewDidHide:(LPPopupListView *)popUpListView selectedIndexes:(NSIndexSet *)selectedIndexes
{
    NSLog(@"popupListViewDidHide - selectedIndexes: %@", selectedIndexes.description);
    
    self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedIndexes];

    self.textView.text = @"";
    [selectedIndexes enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        self.textView.text = [self.textView.text stringByAppendingFormat:@"%@\n", [[self list] objectAtIndex:idx]];
    }];
}

#pragma mark - Array List

- (NSArray *)list
{
    return [NSArray arrayWithObjects:@"Car", @"Motor", @"Airplane", @"Boat", @"Bike",@"Яхта", @"Паровоз", nil];
}

@end