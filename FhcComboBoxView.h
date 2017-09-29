
//
//  FhcComboBoxView.h
//  UltiVisa
//
//  Created by Fan HouCheng on 2017/9/14.
//  Copyright © 2017年 Fan HouCheng. All rights reserved.
//


#import <UIKit/UIKit.h>

@class FhcComboBoxView;

/*! 下拉列表展开动画Duration. */
const static NSTimeInterval comboBoxViewAnimationDuration=0.25;

/*! 下拉列表可现实最大项，建议奇数，以便当前选中的能居中. */
const static NSInteger itemShowCount = 5;

IB_DESIGNABLE
/**
 * This is a ComboBox by UITableView for user to choose item .
 *
 * @note User can customize item view(UITableViewCell) by comboBoxItemViewBlock
 * @attention FhcComboBoxView is a UI class and should therefore only be accessed on the main thread.
 * @code
 [_comb setArrData:arr selectedIndex:6];
 _comb.comboBoxItemSelectedBlock = ^(FhcComboBoxView *comboBoxView, UITableView *tableView, NSIndexPath *indexPath) {
    //清除所有cell被选中状态
    for (TCellScheduler *cell in tableView.visibleCells) {
        [cell setSelectedCell:NO];
    }
    //设置当前cell被选中状态
    TCellScheduler *cell = [tableView cellForRowAtIndexPath:indexPath];
        [cell setSelectedCell:YES];
 };
 
 _comb.comboBoxItemViewBlock = ^UITableViewCell *(FhcComboBoxView *comboBoxView, UITableView *tableView, NSIndexPath *indexPath) {
    NSString *cellNibName = @"TCellScheduler";
    TCellScheduler *cell = [tableView  dequeueReusableCellWithIdentifier:cellNibName];
    if(cell == nil){
        [tableView registerNib:[UINib nibWithNibName:cellNibName bundle:nil] forCellReuseIdentifier:cellNibName];
        cell = [tableView dequeueReusableCellWithIdentifier:cellNibName];
    }
    cell.$width = tableView.$width;
    [cell updateData:arr[indexPath.row] detail:arr[indexPath.row] imgName:@"device_light_green"];
 
    //以下操作针对自定义cell
    [cell setSelectedCell:[_comb selectedIndex] == indexPath.row];
 
    return cell;
 };

 */
@interface FhcComboBoxView : UIView

/*! @brief 单个下拉列表项的高度. */
@property(nonatomic,assign) CGFloat comboBoxItemHeight;
/*! @brief 是否正显示. */
@property(nonatomic,assign,readonly) BOOL isShowing;
/*! @brief 当前文本. */
@property(nonatomic,strong,readonly) NSString* currentText;
/*! @brief placeHolder. */
@property(nonatomic,strong,readwrite) IBInspectable NSString* placeHolder;
/*! @brief 下拉指示图片. */
@property(nonatomic,strong,readwrite) IBInspectable UIImage* indicatorImage;
/*! @brief 自身的textColor. */
@property(nonatomic,strong,readwrite) IBInspectable UIFont* textFont;
/*! @brief 自身的cornerRadius. */
@property(nonatomic,assign,readwrite) IBInspectable CGFloat cornerRadius;
/*! @brief 自身的borderWidth. */
@property(nonatomic,assign,readwrite) IBInspectable CGFloat borderWidth;
/*! @brief 自身的textColor. */
@property(nonatomic,strong,readwrite) IBInspectable UIColor* textColor;
/*! @brief 自身的borderColor. */
@property(nonatomic,strong,readwrite) IBInspectable UIColor* borderColor;//
/*! @brief 下拉列表的BorderColor. */
@property(nonatomic,strong,readwrite) IBInspectable UIColor* dropViewBorderColor;
/*! @brief 下拉列表的BorderWidth. */
@property(nonatomic,assign,readwrite) IBInspectable CGFloat dropViewBorderWidth;
/*! @brief 下拉列表的CornerRadius. */
@property(nonatomic,assign,readwrite) IBInspectable CGFloat dropViewCornerRadius;
/*! @brief 下拉列表项选中后的回调. */
@property (nonatomic,copy) void(^comboBoxItemSelectedBlock)(FhcComboBoxView *comboBoxView, UITableView *tableView, NSIndexPath *indexPath);

/*! @brief 自定义下拉列表项的view. */
@property (nonatomic,copy) UITableViewCell *(^comboBoxItemViewBlock)(FhcComboBoxView *comboBoxView, UITableView *tableView, NSIndexPath *indexPath);
/*! @brief 设置下拉列表数据和当前选中行. */
-(void)setArrData:(NSArray<NSString *> *)arrData selectedIndex:(NSInteger)selectedIndex;
/*! @brief 当前选中行. */
-(NSInteger)selectedIndex;
@end
