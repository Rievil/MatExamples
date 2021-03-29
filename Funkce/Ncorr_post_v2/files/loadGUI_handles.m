%% script to save the GUI settings

inputFileNameNoExt = extractExtension(inputFileName);
load([inputPath,'dataGUI/',inputFileNameNoExt,'_GUI.mat']);

if isfield(plottingData,'version')
    if isfield(plottingData,'listOfExtensometers')
        set(handles.listbox2,'String', plottingData(1).listOfExtensometers)
    end
else
    set(handles.listbox2,'String', 'None defined')
end

handles_title = findobj('Style','text','Tag','text11'); % find handle of static text
set(handles_title,'String',GUI_handles(1).title) % update the static text field

set(handles.edit2,'String',GUI_handles(1).lowerBound);
set(handles.edit3,'String',GUI_handles(1).upperBound);

set(handles.popupmenu1,'Value',GUI_handles(1).currentExtColor);

set(handles.checkbox4,'Value',GUI_handles(1).plotExtensometers);
set(handles.checkbox3,'Value',GUI_handles(1).showOutOfRoi);
set(handles.checkbox1,'Value',GUI_handles(1).autoscaleBounds);

set(handles.slider1,'Value',GUI_handles(1).transparency);
set(handles.listbox1,'Value',GUI_handles(1).currentQuantity);

% enable / disable GUI elements

set(handles.pushbutton10,'Enable',GUI_handles(1).enable_pushbutton10);
set(handles.pushbutton3,'Enable',GUI_handles(1).enable_pushbutton3);
set(handles.pushbutton1,'Enable',GUI_handles(1).enable_pushbutton1);
set(handles.pushbutton2,'Enable',GUI_handles(1).enable_pushbutton2);
set(handles.pushbutton5,'Enable',GUI_handles(1).enable_pushbutton5);
set(handles.pushbutton6,'Enable',GUI_handles(1).enable_pushbutton6);
set(handles.listbox1,'Enable',GUI_handles(1).enable_listbox1);
set(handles.slider1,'Enable',GUI_handles(1).enable_slider1);
set(handles.edit2,'Enable',GUI_handles(1).enable_edit2);
set(handles.edit3,'Enable',GUI_handles(1).enable_edit3);
set(handles.pushbutton17,'Enable',GUI_handles(1).enable_pushbutton17);
set(handles.pushbutton18,'Enable',GUI_handles(1).enable_pushbutton18);
set(handles.pushbutton19,'Enable',GUI_handles(1).enable_pushbutton19);
set(handles.checkbox4,'Enable',GUI_handles(1).enable_checkbox4);
set(handles.popupmenu1,'Enable',GUI_handles(1).enable_popupmenu1);

% additional GUI elements

if strcmp(GUI_handles(1).enable_pushbutton2,'on')
    set(handles.pushbutton21,'Enable','on');
    set(handles.edit4,'Enable','on')
    set(handles.edit10,'Enable','on')
end

if strcmp(GUI_handles(1).enable_pushbutton5,'on')
    set(handles.pushbutton22,'Enable','on');
    set(handles.pushbutton29,'Enable','on');
end

if strcmp(GUI_handles(1).enable_pushbutton6,'on')
    set(handles.pushbutton23,'Enable','on');
    set(handles.pushbutton30,'Enable','on');
end


% GUI of virtual extensometers

set(handles.pushbutton24,'Enable','on');

if isfield(plottingData,'version')
    set(handles.edit5,'Enable',GUI_handles(1).enable_edit5);
    set(handles.edit6,'Enable',GUI_handles(1).enable_edit6);
    set(handles.edit7,'Enable',GUI_handles(1).enable_edit7);
    set(handles.edit8,'Enable',GUI_handles(1).enable_edit8);
    set(handles.edit9,'Enable',GUI_handles(1).enable_edit9);
    
    set(handles.slider6,'Enable',GUI_handles(1).enable_slider6);
    set(handles.slider7,'Enable',GUI_handles(1).enable_slider7);
    set(handles.slider8,'Enable',GUI_handles(1).enable_slider8);
    set(handles.slider9,'Enable',GUI_handles(1).enable_slider9);
    
    set(handles.listbox2,'Enable',GUI_handles(1).enable_listbox2);
    
    set(handles.popupmenu1,'Enable',GUI_handles(1).enable_popupmenu1);
    
    set(handles.pushbutton24,'Enable',GUI_handles(1).enable_pushbutton24);
    set(handles.pushbutton25,'Enable',GUI_handles(1).enable_pushbutton25);
    set(handles.pushbutton26,'Enable',GUI_handles(1).enable_pushbutton26);
    set(handles.pushbutton27,'Enable',GUI_handles(1).enable_pushbutton27);
end