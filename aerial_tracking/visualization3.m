        


%% plot grid history (all the init_grid)
        ind_init_s=ind_init;
        grid_his_s=grid_his;
        loc_idx_list=[];
        
        figure(101);
        [h4,w4]=size(grid_his);
        x=1:w4;
        hold on 
        for i3=1:h4
        plot(x,grid_his(i3,:),'-o')
        
        end
        title('grid history(whole)');
        %% plot grid history (Only grid that has been deleted)
        figure(102)
        hold on 
        for i4=1:numel(killed_his);
        loc_idx=find(ind_init==killed_his(i4));
        plot(x,grid_his(loc_idx,:),'-o')
        loc_idx_list=[loc_idx_list;loc_idx];
        end

        ind_init_s(loc_idx_list)=[];
        grid_his_s(loc_idx_list,:)=[];
         title('killed')
        
        %%
        figure(103);
        [h2,w4]=size(grid_his_s);
        hold on 
        for i5=1:h2
        plot(x,grid_his_s(i5,:),'-o')
        title('survivor')
        
        end
        
         ax = gca; 
%         ax.YLim = [0, 1];
        