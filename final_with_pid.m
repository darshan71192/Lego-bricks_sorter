clear;
clc;
brick = legoev3('usb');

%---main loop---
while(1)
    main_menu(brick);
    button = button_read(brick);
    if(button==3)
        test_all_parts(brick);
        while(1)
            mode_menu(brick);
            button = button_read(brick);
            if(button==2)
                auto_sort(brick);
            elseif(button==4)
                manual_sort(brick);
            elseif(button==1)
                clearLCD(brick);
                pause(0.2);
                break; 
            elseif(button==3)
                clearLCD(brick);
                pause(0.2);
                continue; 
            end
        end
    elseif(button==1)
        pause(0.1);
        clearLCD(brick);
        break;
    end
end
%% 
%--main loop additional functions-

function main_menu(brick)
    clearLCD(brick);
    pause(0.1);
    writeLCD(brick,'-------------------',2,1);
    writeLCD(brick,'    COLOR-SORTER   ',3,1);
    writeLCD(brick,'       GROUP-3     ',4,1);
    writeLCD(brick,'     Me.Sy.2018    ',5,1);
    writeLCD(brick,'-------------------',6,1);
    writeLCD(brick,'   Press RIGHT to  ',7,1);
    writeLCD(brick,'        START      ',8,1);
    pause(0.2);
end

function mode_menu(brick)
    pause(0.2);
    clearLCD(brick);
    pause(0.2);
    writeLCD(brick,'--------MENU-------',4,1);
    writeLCD(brick,'  UP -> Auto-Sort  ',5,1);
    writeLCD(brick,' DOWN-> Manual-Sort',6,1);
    pause(0.2);
end

function pressed = button_read(brick)
    pressed = 0;
    while(pressed==0)
       if(readButton(brick,'left'))
           pressed = 1;
       elseif(readButton(brick,'up'))
           pressed = 2;
       elseif(readButton(brick,'right'))
           pressed = 3;
       elseif(readButton(brick,'down'))
           pressed = 4;
       elseif(readButton(brick,'center'))
           pressed = 5;
       end
    end
end

%% 
%--test_all--
function test_all_parts(brick)
    pause(0.2);    
    clearLCD(brick);
    writeLCD(brick,'------Testing------',3,1);

    revolve_degree(brick,90);
    writeLCD(brick,' Revolve Motor:Pass',5,1);
    
    color_sensor = colorSensor(brick,1);
    color = readColor(color_sensor);
    writeLCD(brick,strcat(' Color: ',color),6,1); 
    writeLCD(brick,' Color Sensor: Pass',7,1);
    
    drop(brick);
    writeLCD(brick,' Deploy Motor: Pass',8,1);

    button_read(brick);
end
%% 
function revolve_degree(brick,degrees)
    kp = 40;
    ki = 4;
    kd = 180;
    intigral = 0;
    last_error = 0;
    revolve_motor = motor(brick,'D');
    resetRotation(revolve_motor);
    zero_error=0;
    
    while(1)
        error = degrees - readRotation(revolve_motor);
        intigral = intigral + error;
        derivative = error - last_error;
        
        revolve_motor.Speed = ((error*kp) + (intigral*ki) + (derivative*kd))/50;        
        start(revolve_motor);
        
        last_error = error;
        if(error==0)
            zero_error = zero_error+1;
        end
        if(zero_error>3)
            revolve_motor.Speed = 0;        
            stop(revolve_motor);
            break;
        end
    end
    revolve_motor.Speed = 0;        
    stop(revolve_motor);
end
%% 
function drop(brick)
    deploy = motor(brick,'A');
    resetRotation(deploy);
    while(readRotation(deploy)<360)
        deploy.Speed = 97;
        deploy.start();
        %revolve.Speed = -100;
    end
    deploy.Speed = -45;
    pause(0.05);
    deploy.stop();
end

%% 
%--Auto sort--
function auto_sort(brick)
    color_sensor = colorSensor(brick,1);
    
    clearLCD(brick);
    writeLCD(brick,'-----Auto_Sort-----',3,1);
    
    red_count = 0;
    green_count = 0;
    blue_count = 0;
    yellow_count = 0;

    past_color = 'red';
    while(~readButton(brick,'left'))
         writeLCD(brick,strcat(' Red Bricks   :',int2str(red_count)),4,1);
         writeLCD(brick,strcat(' Green Bricks :',int2str(green_count)),5,1);
         writeLCD(brick,strcat(' Blue Bricks  :',int2str(blue_count)),6,1);
         writeLCD(brick,strcat(' Yellow Bricks:',int2str(yellow_count)),7,1);
                  
        current_color = readColor(color_sensor);
        
        if(strcmp(current_color,'black'))
            continue;
        else
            sort(current_color,past_color,brick);
        end
        past_color = current_color;
     end%while
end%func_auto

%%
%-Manual Sort--
function manual_sort(brick)
    red_count = 0;
    green_count = 0;
    blue_count = 0;
    yellow_count = 0;
    
    past_color = 'red';
    current_color = 'red';
    
    while(~strcmp(current_color,'black'))
        
        clearLCD(brick);
        writeLCD(brick,'----Manual Sort----',3,1);
        writeLCD(brick,strcat(' Red Bricks   :',int2str(red_count)),4,1);
        writeLCD(brick,strcat(' Green Bricks :',int2str(green_count)),5,1);
        writeLCD(brick,strcat(' Blue Bricks  :',int2str(blue_count)),6,1);
        writeLCD(brick,strcat(' Yellow Bricks:',int2str(yellow_count)),7,1);
        
        pause(0.2);
        button = button_read(brick);
        pause(0.2);
        
        if (button==1)
            current_color = 'red';
            red_count=red_count+1;
        elseif(button==2)
            current_color = 'green';
            green_count=green_count+1;
        elseif(button==3)
            current_color = 'blue';
            blue_count=blue_count+1;
        elseif(button==4)
            current_color = 'yellow';
            yellow_count=yellow_count+1;
        else
            current_color = 'black';
        end
          
        if(strcmp(current_color,past_color))
            drop(brick);
        else
            sort(current_color,past_color,brick);
        end%if
        past_color = current_color;
     end%while
end

%% 
%sort fnnction
function sort(current_color,past_color,brick)
    if(strcmp(current_color,'red'))
                if(strcmp(past_color,'yellow'))
                    revolve_degree(brick,90);
                    drop(brick);
                elseif(strcmp(past_color,'blue'))
                    revolve_degree(brick,180);
                    drop(brick);
                elseif(strcmp(past_color,'green'))
                    revolve_degree(brick,-90);
                    drop(brick);
                else
                    drop(brick);
                end
    elseif(strcmp(current_color,'green')) 
                if(strcmp(past_color,'red'))
                    revolve_degree(brick,90);
                    drop(brick);
                elseif(strcmp(past_color,'yellow'))
                    revolve_degree(brick,180);
                    drop(brick);
                elseif(strcmp(past_color,'blue'))
                    revolve_degree(brick,-90);
                    drop(brick);
                else
                    drop(brick);
                end
    elseif(strcmp(current_color,'blue'))
                if(strcmp(past_color,'green'))
                    revolve_degree(brick,90);
                    drop(brick);
                elseif(strcmp(past_color,'red'))
                    revolve_degree(brick,180);
                    drop(brick);
                elseif(strcmp(past_color,'yellow'))
                    revolve_degree(brick,-90);
                    drop(brick);
                else
                    drop(brick);
                end
    elseif(strcmp(current_color,'yellow'))
                if(strcmp(past_color,'blue'))
                    revolve_degree(brick,90);
                    drop(brick);
                elseif(strcmp(past_color,'green'))
                    revolve_degree(brick,180);
                    drop(brick);
                elseif(strcmp(past_color,'red'))
                    revolve_degree(brick,-90);
                    drop(brick);
                else
                    drop(brick);
                end
    end
end