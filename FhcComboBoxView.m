
#import "FhcComboBoxView.h"
#import "CommonDefine.h"


@interface FhcComboBoxView()<UITableViewDelegate,UITableViewDataSource,UIGestureRecognizerDelegate>
{
    UITableView* _tableView;
    NSIndexPath* _selectedIndexPath;
    UILabel* _textLabel;
    UIImageView* _indicatorImageView;
    BOOL _isAnimating;
    CGFloat _oldContentOffsetY;
    NSMutableArray<NSString *> *_arrData;
}

@end

@implementation FhcComboBoxView
-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}
-(instancetype)initWithFrame:(CGRect)frame{
    if (self=[super initWithFrame:frame]) {
        [self configUI];
    }
    return self;
}
-(instancetype)initWithCoder:(NSCoder *)aDecoder{
    if(self=[super initWithCoder:aDecoder]){
        [self configUI];
    }
    return self;
}
-(void)configUI{
    _comboBoxItemHeight = 40;
    _tableView=[[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    if ([_tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [_tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([_tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [_tableView setLayoutMargins:UIEdgeInsetsZero];
    }
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
    _textLabel=[[UILabel alloc]init];
    _textColor=[UIColor lightGrayColor];
    _textLabel.textColor=_textColor;
    _textFont = [UIFont systemFontOfSize:13];;
    _textLabel.font=_textFont;
    [self addSubview:_textLabel];
    
    UITapGestureRecognizer* tapGesture=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(onComboBoxViewTap:)];
    tapGesture.delegate=self;
    [self addGestureRecognizer:tapGesture];
}

-(void)setArrData:(NSMutableArray<NSString *> *)arrData selectedIndex:(NSInteger)selectedIndex{
    _arrData = [[NSMutableArray alloc]initWithArray:arrData];
    _selectedIndexPath =[NSIndexPath indexPathForRow:selectedIndex inSection:0];
    if(0 <= selectedIndex < _arrData.count - 1){
        _textLabel.text=_arrData[selectedIndex];
    }
    [_tableView reloadData];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    
    CGRect selfFrame=self.frame;

    //placeholder
    CGRect textLabelFrame=_textLabel.frame;
    CGRect textLabelRect=[_textLabel.text boundingRectWithSize:selfFrame.size options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:_textFont} context:nil];
    textLabelFrame.origin.y=(selfFrame.size.height-textLabelRect.size.height)/2;
    textLabelFrame.origin.x=10;
    textLabelFrame.size.height=textLabelRect.size.height;
    textLabelFrame.size.width=selfFrame.size.width-10-_indicatorImageView.frame.size.width;
    _textLabel.frame=textLabelFrame;
    //indicatorImageView
}
-(UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    //会连续调用两次
    if (_isShowing&&!_isAnimating) {
        BOOL isPointInTableView=[_tableView pointInside:point withEvent:event];
        BOOL isPointInSelf=[self pointInside:point withEvent:event];
        if (!isPointInSelf&&!isPointInTableView) {
            _isAnimating=true;
            [self comboBoxViewIndicatorAnimate];
            [self comboBoxViewAnimate];
        }
    }
    return [super hitTest:point withEvent:event];
}

#pragma mark --UITapGestureRecognizer
-(void)onComboBoxViewTap:(UITapGestureRecognizer*)tapGesture{
    if (_isAnimating) return;
    _isAnimating=true;
    [self comboBoxViewIndicatorAnimate];
    [self comboBoxViewAnimate];
}

-(void)comboBoxViewAnimate{
    CGFloat heightShow;
    if(_arrData.count <= itemShowCount){
        heightShow = _comboBoxItemHeight * _arrData.count;
    }else{
        heightShow = _comboBoxItemHeight * itemShowCount;
    }
    BOOL isPopToUp = NO;
    CGRect frame=_tableView.frame;
    if (_tableView.superview==nil) {
        frame = self.frame;
        if(self.frame.origin.y + self.frame.size.height + heightShow > FullHeight){
            frame.origin.y = frame.origin.y - 1;
            frame.size.height = 0;
            isPopToUp = YES;
        }else{
            frame.origin.y = self.frame.origin.y + self.frame.size.height - 1;
        }
        _tableView.frame = frame;
        [self.window addSubview:_tableView];
    }else{
        isPopToUp = frame.origin.y < self.frame.origin.y;
        if(isPopToUp){
            frame = self.frame;
            frame.size.height = 0;
        }
    }
    
    if (_isShowing) {
        frame.size.height=0;
    }else{
        frame.size.height = heightShow;
        if(isPopToUp){
            frame.origin.y = frame.origin.y - heightShow;
        }
    }

    [UIView animateWithDuration:comboBoxViewAnimationDuration animations:^{
        _tableView.frame=frame;
    } completion:^(BOOL finished) {
        if (_isShowing) {
            [_tableView removeFromSuperview];
        }else{
            if (_selectedIndexPath && _arrData.count > itemShowCount) {
                NSIndexPath *pathMax = [_tableView indexPathForCell:_tableView.visibleCells[_tableView.visibleCells.count - 1]];
                NSIndexPath *pathMin = [_tableView indexPathForCell:_tableView.visibleCells[0]];
                if(_selectedIndexPath.row > pathMax.row || _selectedIndexPath.row < pathMin.row){
                    [_tableView scrollToRowAtIndexPath:_selectedIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
                }
            }
        }
        _isShowing=!_isShowing;
        _isAnimating=FALSE;
    }];
    
    
}

-(void)comboBoxViewIndicatorAnimate{
    if (_indicatorImageView) {
        [UIView animateWithDuration:comboBoxViewAnimationDuration animations:^{
            _indicatorImageView.transform=CGAffineTransformRotate(_indicatorImageView.transform, M_PI);
        } completion:^(BOOL finished) {
            
        }];
    }
}
#pragma mark --UITableViewDelegate & UITableViewDataSource

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
        
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _arrData.count;
}
-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell* cell;
    if (_comboBoxItemViewBlock) {
        cell = _comboBoxItemViewBlock(self, tableView, indexPath);
    }
    
    if (cell == nil) {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        
        //cell = [tableView dequeueReusableCellWithIdentifier:@"ComboBoxViewCellIdentifier"];
        cell.textLabel.text=_arrData[indexPath.row];
        cell.textLabel.textColor=_textColor;
        cell.textLabel.font=_textFont;
    }
    
  
   
    
//    UIImage *icon = [UIImage imageNamed:@"down_arrow"];
//    CGSize itemSize = CGSizeMake(20, 20);
//    UIGraphicsBeginImageContextWithOptions(itemSize, NO ,0.0);
//    CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
//    [icon drawInRect:imageRect];
//    cell.imageView.image = UIGraphicsGetImageFromCurrentImageContext();
//    UIGraphicsEndImageContext();
    
//    if (_selectedIndexPath.row == indexPath.row) {
//        [tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
//    }
    return cell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return _comboBoxItemHeight;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //[tableView reloadRowsAtIndexPaths:@[_selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    [self comboBoxViewIndicatorAnimate];
    [self comboBoxViewAnimate];
    _selectedIndexPath=indexPath;

    if (self.comboBoxItemSelectedBlock) {
        self.comboBoxItemSelectedBlock(self, tableView,  _selectedIndexPath);
    }
    _textLabel.text=_arrData[indexPath.row];
}


#pragma mark - scrollView 停止滚动监测
//有3种停止滚动类型，分别是：1、快速滚动，自然停止；2、快速滚动，手指按压突然停止；3、慢速上下滑动停止。
//停止后把最上或者最下显示完整
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    _oldContentOffsetY = scrollView.contentOffset.y;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"Did Scroll");
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 停止类型1、停止类型2
    BOOL scrollToScrollStop = !scrollView.tracking && !scrollView.dragging &&    !scrollView.decelerating;
    if (scrollToScrollStop) {
        [self scrollViewDidEndScroll:scrollView];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        // 停止类型3
        BOOL dragToDragStop = scrollView.tracking && !scrollView.dragging && !scrollView.decelerating;
        if (dragToDragStop) {
            [self scrollViewDidEndScroll:scrollView];
        }
    }
}


- (void)scrollViewDidEndScroll:(UIScrollView *)scrollView {
    BOOL isScrollUp = scrollView.contentOffset.y < _oldContentOffsetY;
    if(isScrollUp){
        NSIndexPath *path = [_tableView indexPathForCell:_tableView.visibleCells[0]];
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }else{
        NSIndexPath *path = [_tableView indexPathForCell:_tableView.visibleCells[_tableView.visibleCells.count - 1]];
        [_tableView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    }
}


-(NSInteger)selectedIndex{
    if(_selectedIndexPath){
        return _selectedIndexPath.row;
    }
    return  -1;
}

#pragma mark --Getter & Setter
-(NSString*)currentText{
    return _textLabel.text;
}
-(void)setPlaceHolder:(NSString *)placeHolder{
    _placeHolder=placeHolder;
    _textLabel.text=_placeHolder;
}
-(void)setTextColor:(UIColor *)textColor{
    _textColor=textColor;
    _textLabel.textColor=_textColor;
}
-(void)setTextFont:(UIFont *)textFont{
    _textFont=textFont;
    _textLabel.font=_textFont;
}
-(void)setIndicatorImage:(UIImage *)indicatorImage{
    _indicatorImage=indicatorImage;
    if (_indicatorImageView==nil) {
        _indicatorImageView=[[UIImageView alloc]init];
        _indicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:_indicatorImageView];
    }
    CGFloat offset = (self.frame.size.height - 26)/2;
    CGRect frame= CGRectMake(self.frame.size.width -offset - 26, offset, 26, 26);
    _indicatorImageView.frame=frame;
    
    _indicatorImageView.image=_indicatorImage;
}
-(void)setBorderColor:(UIColor *)borderColor{
    _borderColor=borderColor;
    self.layer.borderColor=_borderColor.CGColor;
}
-(void)setBorderWidth:(CGFloat)borderWidth{
    _borderWidth=borderWidth;
    self.layer.borderWidth=_borderWidth;
}

-(void)setDropViewBorderColor:(UIColor *)borderColor{
    _dropViewBorderColor=borderColor;
    _tableView.layer.borderColor=_dropViewBorderColor.CGColor;
}
-(void)setDropViewBorderWidth:(CGFloat)borderWidth{
    _dropViewBorderWidth=borderWidth;
    _tableView.layer.borderWidth=_dropViewBorderWidth;
}

-(void)setCornerRadius:(CGFloat)cornerRadius{
    _cornerRadius=cornerRadius;
    self.layer.cornerRadius=_cornerRadius;
}


-(void)setDropViewCornerRadius:(CGFloat)cornerRadius{
    _dropViewCornerRadius=cornerRadius;
    _tableView.layer.cornerRadius=_dropViewCornerRadius;
}

-(void)dealloc{
    _tableView=nil;
    _textLabel=nil;
    _indicatorImageView=nil;
    _indicatorImage=nil;
}
@end
