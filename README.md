# ComboxView

<red>A better ComboxView for iOS</red>
</br>QQ:5032441
</br>I think there is no any other ComboxView is better than this.

</br></br>1.If ComboxView on bottom ，will pop up
</br>2.If ComboxView on top，will pop down
</br>3.Support customization item
</br>4.Support IB_DESIGNABLE

Sample code:
 
    _comb.textFont = LFont;
    _comb.cornerRadius =2;
    _comb.dropViewBorderColor = [UIColor redColor];
    _comb.dropViewBorderWidth = 2;
    _comb.comboBoxItemHeight = 49;
    [_comb addBorder:ViewBorderDirectionBottom style:ViewBorderStyleSolid];
    NSArray *arr = @[@"11",@"22",@"33",@"44",@"55",@"66",@"77",@"88",@"99",@"aa"];
    [_comb setArrData:arr selectedIndex:4];    
    
    //以下操作针对自定义cell 
    _comb.comboBoxItemSelectedBlock = ^(FhcComboBoxView *comboBoxView, UITableView *tableView, NSIndexPath *indexPath) {
       //清除所有cell被选中状态
       for (TCellScheduler *cell in tableView.visibleCells) {
           [cell setSelectedCell:NO];
       }
       //设置当前cell被选中状态
       TCellScheduler *cell = [tableView cellForRowAtIndexPath:indexPath];
       [cell setSelectedCell:YES];
       
       NSLog(@"comboBoxItemSelectedBlock %d",indexPath.row);
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

  
