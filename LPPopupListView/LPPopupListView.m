//
//  LPPopupListView.m
//
//  Created by Luka Penger on 27/03/14.
//  Copyright (c) 2014 Luka Penger. All rights reserved.
//

// This code is distributed under the terms and conditions of the MIT license.
//
// Copyright (c) 2014 Luka Penger
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "LPPopupListView.h"
#import <DAKeyboardControl/DAKeyboardControl.h>


#define navigationBarHeight 44.0f
#define separatorLineHeight 1.0f
#define closeButtonWidth 44.0f
#define navigationBarTitlePadding 12.0f
#define animationsDuration 0.25f

@interface CIdxTitle : NSObject

@property (nonatomic) NSInteger idx;
@property (nonatomic, strong) NSString *title;

@end

@implementation CIdxTitle
@end

@interface LPPopupListView () <UISearchBarDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *arrayList;
@property (nonatomic, strong) NSArray *arrayFilteredList;
@property (nonatomic, strong) NSString *navigationBarTitle;
@property (nonatomic, assign) BOOL isMultipleSelection;
@property (nonatomic, strong) UISearchBar *searchBar;
@property (nonatomic, strong) UIView *contentView;

@property (nonatomic) CGFloat keybHeight;

@end


@implementation LPPopupListView
{
    //Content View
    
}

static BOOL isShown = false;

#pragma mark - Lifecycle

- (id)initWithTitle:(NSString *)title list:(NSArray *)list selectedIndexes:(NSIndexSet *)selectedList point:(CGPoint)point size:(CGSize)size multipleSelection:(BOOL)multipleSelection disableBackgroundInteraction:(BOOL)diableInteraction {
    return [self initWithTitle:title list:list selectedIndexes:selectedList point:point size:size multipleSelection:multipleSelection disableBackgroundInteraction:diableInteraction enableFilterBar:NO];
}

- (id)initWithTitle:(NSString *)title list:(NSArray *)list selectedIndexes:(NSIndexSet *)selectedList point:(CGPoint)point size:(CGSize)size multipleSelection:(BOOL)multipleSelection disableBackgroundInteraction:(BOOL)diableInteraction enableFilterBar:(BOOL)enableFilterBar
{
    CGRect contentFrame = CGRectMake(point.x, point.y,size.width,size.height);
    
    //Disable background Interaction
    if (diableInteraction)
    {
        self = [super initWithFrame:[UIScreen mainScreen].bounds];
    }
    else
    {
        self = [super initWithFrame:contentFrame];
        contentFrame = CGRectMake(0, 0, size.width, size.height);
    }
    
    
    if (self)
    {
        //Content View
        self.contentView = [[UIView alloc] initWithFrame:contentFrame];
        
        self.contentView.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(108.0/255.0) blue:(192.0/255.0) alpha:0.7];
        
        self.cellHighlightColor = [UIColor colorWithRed:(0.0/255.0) green:(60.0/255.0) blue:(127.0/255.0) alpha:0.5f];
        
        self.navigationBarTitle = title;
        NSMutableArray *arrTmp = [NSMutableArray new];
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CIdxTitle *item = [CIdxTitle new];
            item.idx = idx;
            item.title = obj;
            [arrTmp addObject:item];
        }];
        self.arrayList = [NSArray arrayWithArray:arrTmp];
        [self filterListWithText:@""];
        self.selectedIndexes = [[NSMutableIndexSet alloc] initWithIndexSet:selectedList];
        self.isMultipleSelection = multipleSelection;

        self.navigationBarView = [[UIView alloc] init];
        self.navigationBarView.backgroundColor = [UIColor colorWithRed:(0.0/255.0) green:(108.0/255.0) blue:(192.0/255.0) alpha:0.7];
        [self.contentView addSubview:self.navigationBarView];

        self.separatorLineView = [[UIView alloc] init];
        self.separatorLineView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:self.separatorLineView];
        
        self.titleLabel = [[UILabel alloc] init];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.text = self.navigationBarTitle;
        self.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.titleLabel.textColor = [UIColor whiteColor];
        [self.navigationBarView addSubview:self.titleLabel];
        
        self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [self.closeButton setImage:[UIImage imageNamed:@"closeButton"] forState:UIControlStateNormal];
        [self.closeButton addTarget:self action:@selector(closeButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
        [self.navigationBarView addSubview:self.closeButton];
        
        self.tableView = [[UITableView alloc] init];
        self.tableView.dataSource = self;
        self.tableView.delegate = self;
        self.tableView.separatorColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        self.tableView.backgroundColor = [UIColor clearColor];
        self.tableView.tableFooterView = [UIView new];
        
        if(enableFilterBar){
            self.searchBar = [[UISearchBar alloc] initWithFrame:(CGRect){0,0, size.width, 44}];
            self.searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            self.searchBar.delegate = self;
            self.tableView.tableHeaderView = self.searchBar;
        }
        [self.contentView addSubview:self.tableView];
        
        self.checkmarkImage = [UIImage imageNamed:@"checkMark"];
        self.cellHeight = navigationBarHeight;
        
        [self addSubview:self.contentView];
        self.keybHeight = 0;
        __weak typeof(self) weakSelf = self;
        [self addKeyboardPanningWithFrameBasedActionHandler:^(CGRect keyboardFrameInView, BOOL opening, BOOL closing) {
            weakSelf.keybHeight = keyboardFrameInView.size.height;
            weakSelf.tableView.frame = CGRectMake(0.0f, (navigationBarHeight + separatorLineHeight), weakSelf.contentView.frame.size.width, (weakSelf.contentView.frame.size.height-(navigationBarHeight + separatorLineHeight + weakSelf.keybHeight)));
        } constraintBasedActionHandler:nil];
    }
    return self;
}

- (void)dealloc {
    [self removeKeyboardControl];
}

- (void)setContentBackgroundColor:(UIColor *)contentBackgroundColor {
    _contentBackgroundColor = contentBackgroundColor;
    _contentView.backgroundColor = _contentBackgroundColor;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
    [super setBackgroundColor:backgroundColor];
    if(!_contentBackgroundColor)
        _contentView.backgroundColor = backgroundColor;
}

- (void)setCellSeparatorColor:(UIColor *)cellSeparatorColor {
    _cellSeparatorColor = cellSeparatorColor;
    self.tableView.separatorColor = _cellSeparatorColor;
}

- (void)setFilterPlaceholder:(NSString *)filterPlaceholder {
    _filterPlaceholder = filterPlaceholder;
    if(self.searchBar){
        self.searchBar.placeholder = _filterPlaceholder;
    }
}

- (void)filterListWithText:(NSString*)filterText {
    
    if(!filterText.length)
        self.arrayFilteredList = [NSArray arrayWithArray:self.arrayList];
    else {
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF.title CONTAINS[cd] %@", filterText];
        self.arrayFilteredList = [self.arrayList filteredArrayUsingPredicate:pred];
    }
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    [self filterListWithText:searchText];
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    UIBezierPath *shadowPath = [UIBezierPath bezierPathWithRect:_contentView.bounds];
    _contentView.layer.masksToBounds = NO;
    _contentView.layer.shadowColor = [UIColor blackColor].CGColor;
    _contentView.layer.shadowOffset = CGSizeMake(0.0f, 0.0f);
    _contentView.layer.shadowOpacity = 0.5f;
    _contentView.layer.shadowPath = shadowPath.CGPath;
    
    self.navigationBarView.frame = CGRectMake(0.0f, 0.0f, _contentView.frame.size.width, navigationBarHeight);
    
    self.separatorLineView.frame = CGRectMake(0.0f, self.navigationBarView.frame.size.height, _contentView.frame.size.width, separatorLineHeight);
    
    self.closeButton.frame = CGRectMake((self.navigationBarView.frame.size.width-closeButtonWidth), 0.0f, closeButtonWidth, self.navigationBarView.frame.size.height);
    
    self.titleLabel.frame = CGRectMake(navigationBarTitlePadding, 0.0f, (self.navigationBarView.frame.size.width-closeButtonWidth-(navigationBarTitlePadding * 2)), navigationBarHeight);
    
    self.tableView.frame = CGRectMake(0.0f, (navigationBarHeight + separatorLineHeight), _contentView.frame.size.width, (_contentView.frame.size.height-(navigationBarHeight + separatorLineHeight + self.keybHeight)));
}

- (void)closeButtonClicked:(id)sender
{
    [self hideAnimated:self.closeAnimated];
}

#pragma mark - UITableView DataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.cellHeight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.arrayFilteredList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"LPPopupListViewCell";
    
    LPPopupListViewCell *cell = [[LPPopupListViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    cell.highlightColor = self.cellHighlightColor;
    CIdxTitle *item = self.arrayFilteredList[indexPath.row];
    cell.textLabel.text = item.title;
    cell.textColor = self.cellTextColor;
    cell.font = self.cellTextFont;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
//    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:item.idx]) {
            cell.rightImageView.image = _checkmarkImage;
        } else {
            cell.rightImageView.image = nil;
        }
//    }
    
    return cell;
}

#pragma mark - UITableView Delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (self.isMultipleSelection) {
        if ([self.selectedIndexes containsIndex:indexPath.row]) {
            [self.selectedIndexes removeIndex:indexPath.row];
        } else {
            [self.selectedIndexes addIndex:indexPath.row];
        }

        [self.tableView reloadData];
    } else {
        isShown = false;
        
        if ([self.delegate respondsToSelector:@selector(popupListView:didSelectIndex:)]) {
            [self.delegate popupListView:self didSelectIndex:indexPath.row];
        }
        
        [self hideAnimated:self.closeAnimated];
    }
}

#pragma mark - Instance methods

- (void)showInView:(UIView *)view animated:(BOOL)animated
{
    if(!isShown) {
        isShown = true;
        self.closeAnimated = animated;
        
        if(animated) {
            _contentView.alpha = 0.0f;
            [view addSubview:self];
            
            [UIView animateWithDuration:animationsDuration animations:^{
                _contentView.alpha = 1.0f;
            }];
        } else {
            [view addSubview:self];
        }
    }
}

- (void)hideAnimated:(BOOL)animated
{
    if (animated) {
        [UIView animateWithDuration:animationsDuration animations:^{
            _contentView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            isShown = false;
            
            if (self.isMultipleSelection) {
                if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                    [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
                }
            }
            
            [self removeFromSuperview];
        }];
    } else {
        isShown = false;
        
        if (self.isMultipleSelection) {
            if ([self.delegate respondsToSelector:@selector(popupListViewDidHide:selectedIndexes:)]) {
                [self.delegate popupListViewDidHide:self selectedIndexes:self.selectedIndexes];
            }
        }
        
        [self removeFromSuperview];
    }
}

@end
