//
//  LPListViewModel.h
//  LPPopupListViewExample
//
//  Created by Eugene Matveev on 28.12.15.
//  Copyright © 2015 Luka Penger. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LPPopupListView.h"

@class RACSignal;

@interface LPListViewModel : NSObject <LPPopupViewModelProtocol>

@property (nonatomic, readonly) RACSignal *titleSignal;
@property (nonatomic, strong) NSString *filterText;
@property (nonatomic, readonly) RACSignal *listSignal;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, readonly) RACSignal *executingSignal;
@property (nonatomic, strong) NSString *errorMessage;
@property (nonatomic, readonly) NSString *emptyMessage;

@property (nonatomic, readonly) NSString *okButtonTitle;
@property (nonatomic, readonly) NSString *cancelButtonTitle;

- (instancetype)initWithTitle:(NSString*)title;

@end
