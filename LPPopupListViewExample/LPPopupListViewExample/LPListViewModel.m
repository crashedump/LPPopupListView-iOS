//
//  LPListViewModel.m
//  LPPopupListViewExample
//
//  Created by Eugene Matveev on 28.12.15.
//  Copyright © 2015 Luka Penger. All rights reserved.
//

#import "LPListViewModel.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface LPListViewModel ()

@property (nonatomic, readwrite) RACSignal *titleSignal;
@property (nonatomic, readwrite) RACSignal *listSignal;
@property (nonatomic, readwrite) RACSignal *executingSignal;

@property (nonatomic, strong) NSString *title;
@property (nonatomic) BOOL executing;
@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, strong) NSArray *filteredList;
@property (nonatomic, readwrite) NSString *emptyMessage;

@property (nonatomic, readwrite) NSString *okButtonTitle;
@property (nonatomic, readwrite) NSString *cancelButtonTitle;

@end

@implementation LPListViewModel

- (instancetype)initWithTitle:(NSString*)title {
    self = [super init];
    
    self.titleSignal = RACObserve(self, title);
    self.executingSignal = RACObserve(self, executing);
    self.listSignal = RACObserve(self, filteredList);
    
    self.arrayList = @[@"One", @"Два", @"Three", @"Четыре", @"Five", @"Шесть"];
    
    self.emptyMessage = @"Не найдено";
    self.okButtonTitle = @"Ок";
    self.cancelButtonTitle = @"Отмена";
    
    @weakify(self)
    [RACObserve(self, filterText) subscribeNext:^(NSString * x) {
        @strongify(self)
        self.executing = YES;
        if(x.length){
            self.filteredList = [self.arrayList.rac_sequence filter:^BOOL(NSString * value) {
                NSRange rng = [value rangeOfString:x options:NSCaseInsensitiveSearch];
                return rng.length;
            }].array;
        } else {
            self.filteredList = [NSArray arrayWithArray:self.arrayList];
        }
        self.executing = NO;
    }];
    
    self.title = title;
    self.executing = NO;
    
    [[RACObserve(self, selectedIndexPath) filter:^BOOL(id value) {
        return value != nil;
    }] subscribeNext:^(NSIndexPath * x) {
        NSLog(@"s: %ld, r: %ld", (long)x.section, (long)x.row);
        NSLog(@"v: %@", self.filteredList[x.row]);
    }];
    
    return self;
}

@end
