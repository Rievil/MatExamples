%% script to save the GUI settings

GUI_handles = struct;

handles_title = findobj('Style','text','Tag','text11'); % find handle of static text
GUI_handles(1).title = get(handles_title,'String');

GUI_handles(1).lowerBound = get(handles.edit2,'String');
GUI_handles(1).upperBound = get(handles.edit3,'String');

GUI_handles(1).currentExtColor = get(handles.popupmenu1,'Value');

GUI_handles(1).plotExtensometers = get(handles.checkbox4,'Value');
GUI_handles(1).showOutOfRoi = get(handles.checkbox3,'Value');
GUI_handles(1).autoscaleBounds = get(handles.checkbox1,'Value');

GUI_handles(1).transparency = get(handles.slider1,'Value');
GUI_handles(1).currentQuantity = get(handles.listbox1,'Value');


% enable / disable GUI elements

GUI_handles(1).enable_pushbutton10 = get(handles.pushbutton10,'Enable');
GUI_handles(1).enable_pushbutton3 = get(handles.pushbutton3,'Enable');
GUI_handles(1).enable_pushbutton1 = get(handles.pushbutton1,'Enable');
GUI_handles(1).enable_pushbutton2 = get(handles.pushbutton2,'Enable');
GUI_handles(1).enable_pushbutton5 = get(handles.pushbutton5,'Enable');
GUI_handles(1).enable_pushbutton6 = get(handles.pushbutton6,'Enable');
GUI_handles(1).enable_listbox1 = get(handles.listbox1,'Enable');
GUI_handles(1).enable_slider1 = get(handles.slider1,'Enable');
GUI_handles(1).enable_edit2 = get(handles.edit2,'Enable');
GUI_handles(1).enable_edit3 = get(handles.edit3,'Enable');
GUI_handles(1).enable_pushbutton17 = get(handles.pushbutton17,'Enable');
GUI_handles(1).enable_pushbutton18 = get(handles.pushbutton18,'Enable');
GUI_handles(1).enable_pushbutton19 = get(handles.pushbutton19,'Enable');
GUI_handles(1).enable_checkbox4 = get(handles.checkbox4,'Enable');

% GUI of virtual extensometers

GUI_handles(1).enable_edit5 = get(handles.edit5,'Enable');
GUI_handles(1).enable_edit6 = get(handles.edit6,'Enable');
GUI_handles(1).enable_edit7 = get(handles.edit7,'Enable');
GUI_handles(1).enable_edit8 = get(handles.edit8,'Enable');
GUI_handles(1).enable_edit9 = get(handles.edit9,'Enable');

GUI_handles(1).enable_slider6 = get(handles.slider6,'Enable');
GUI_handles(1).enable_slider7 = get(handles.slider7,'Enable');
GUI_handles(1).enable_slider8 = get(handles.slider8,'Enable');
GUI_handles(1).enable_slider9 = get(handles.slider9,'Enable');

GUI_handles(1).enable_listbox2 = get(handles.listbox2,'Enable');

GUI_handles(1).enable_popupmenu1 = get(handles.popupmenu1,'Enable');

GUI_handles(1).enable_pushbutton24 = get(handles.pushbutton24,'Enable');
GUI_handles(1).enable_pushbutton25 = get(handles.pushbutton25,'Enable');
GUI_handles(1).enable_pushbutton26 = get(handles.pushbutton26,'Enable');
GUI_handles(1).enable_pushbutton27 = get(handles.pushbutton27,'Enable');


% save the structure to a file
save(strcat('savedProjects/dataGUI/',char(plottingData(1).projectName),'_GUI.mat'), 'GUI_handles')
