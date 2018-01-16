%%
%-----brick_setup & var_init-----%%
clear;
clc;

brick = legoev3('usb');
deploy = motor(brick,'A');
conveyer = motor(brick,'B');
touch_sensor = touchSensor(brick,1);
color_sensor = colorSensor(brick,3);
clearLCD(brick);

%%
%---main loop---
while(1)
    %clearLCD(brick);
    writeLCD(brick,'-------------------',2,1);
    writeLCD(brick,'    COLOR-SORTER   ',3,1);
    writeLCD(brick,'       GROUP-3     ',4,1);
    writeLCD(brick,'     Me.Sy.2018    ',5,1);
    writeLCD(brick,'-------------------',6,1);
    writeLCD(brick,'  press CENTER to  ',7,1);
    writeLCD(brick,'        START      ',8,1);
	
    if(readButton(brick,'center'))
        clearLCD(brick);
        writeLCD(brick,'Testing....',5,5);
        test_all();
            
        while(~readButton(brick,'left'))
            clearLCD(brick);
            writeLCD(brick,'--------MENU-------',4,1);
            writeLCD(brick,'  UP -> Auto-Sort  ',5,1);
            writeLCD(brick,' DOWN-> Manual-Sort',6,1);
            writeLCD(brick,' LEFT-> Exit       ',8,1);
            
            if(readButton(brick,'up'))
                auto_sort(brick,touch_sensor,color_sensor,conveyer,deploy);
            elseif(readButton(brick,'down'))
                manual_sort(touch_sensor,color_sensor,conveyer,deploy);
            end
        end
    end
end

%%
%%--Auto sort--%%

function auto_sort(brick,touch_sensor,color_sensor,conveyer,deploy)
    
    clearLCD(brick);
    writeLCD(brick,'-----Auto_Sort-----',3,1);
    
    red_count = 0;
    green_count = 0;
    blue_count = 0;
    yellow_count = 0;

    past_color = 'red';
    
    red_bucket = 0;
    green_bucket = 220;
    blue_bucket = 450;
    yellow_bucket = 650;
    toHome(touch_sensor,conveyer,deploy);
    
    %conveyer_goLeft(conveyer,green_bucket+120);
    %conveyer_goRight(conveyer,yellow_bucket-100);
   
    
     while(~readButton(brick,'left'))
            
         writeLCD(brick,strcat(' Red Bricks   :',int2str(red_count)),4,1);
         writeLCD(brick,strcat(' Green Bricks :',int2str(red_count)),5,1);
         writeLCD(brick,strcat(' Blue Bricks  :',int2str(red_count)),6,1);
         writeLCD(brick,strcat(' Yellow Bricks:',int2str(red_count)),7,1);
                  
         current_color = readColor(color_sensor);
    
        if(strcmp(current_color,'black'))
            continue;
        %elseif(strcmp(current_color,past_color))
            %drop(deploy);
        else
            if(strcmp(current_color,'yellow'))
                yellow_count=yellow_count+1;
                conveyer_goRight(conveyer,yellow_bucket-80);
                drop(deploy);
            
            elseif(strcmp(current_color,'red'))
                red_count=red_count+1;
                conveyer_goLeft(conveyer,red_bucket+100);
                drop(deploy);
            
            elseif(strcmp(current_color,'green')) 
                green_count=green_count+1;
                if(strcmp(past_color,'red'))
                    conveyer_goRight(conveyer,green_bucket-50);
                    drop(deploy);
                else
                    conveyer_goLeft(conveyer,green_bucket+100);
                    drop(deploy);
                end
                
            elseif(strcmp(current_color,'blue'))
                blue_count=blue_count+1;
                if(strcmp(past_color,'yellow'))
                    conveyer_goLeft(conveyer,blue_bucket);
                    drop(deploy);
                else
                    conveyer_goRight(conveyer,blue_bucket-80);
                    drop(deploy);
                end
            end%inner if
        end%if
        past_color = current_color;
     end%while
    
    %toHome(touch_sensor,conveyer,deploy);
    %deploy.Speed = 50;
    %start(deploy); 
    %pause(0.5);
    %stop(deploy);
    %stop(conveyer);
    
end%func_auto

%%
%%-Manual Sort--%%
function manual_sort(brick,touch_sensor,color_sensor,conveyer,deploy)


end

%%
%%--Additional_Functions--%%
function conveyer_goLeft(conveyer,pos)
    while(readRotation(conveyer) > pos)
    start(conveyer);
    conveyer.Speed = -70;
    end
    %conveyer.Speed = 0;
    stop(conveyer);
end

function conveyer_goRight(conveyer,pos)
    while(readRotation(conveyer) < pos)
    start(conveyer);
    conveyer.Speed = 70;
    end
    %conveyer.Speed = 0;
    stop(conveyer);
end

function drop(deploy)
    deploy.Speed = -70;
    start(deploy);
    pause(0.5);
    deploy.Speed = 70;
    pause(0.5);
    stop(deploy);
end

function toHome(touch,conveyer,deploy)
    while(readTouch(touch) ~= 1)
        conveyer_goLeft(conveyer,0);
    end
    resetRotation(conveyer);
    resetRotation(deploy);
end
