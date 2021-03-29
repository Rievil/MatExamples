function mouseMove(object, eventdata, handles)
    if ~isfield(handles, 'side_pointer') || ~ishandle(handles.side_pointer)
      pointersize = 30;
      handles.side_pointer = scatter(nan, nan, pointersize, 'y', 'Marker', '*');
      guidata(object, handles);
    end
    C = get(handles.Main_Axes, 'CurrentPoint');
    x = C(1,1); y = C(1,2);
    %move the cursor
    set(handles.side_pointer, 'XData', x, 'YData', y);
    %zoom around the cursor
    zoomwidth = 64;
    xleft = max(0, x-zoomwidth/2);
    ybot = max(0, y-zoomwidth/2);
    set(handles.Side_Axes, 'XLim', [xleft xleft+zoomwidth], 'YLim', [ybot ybot+zoomwidth]);
    drawnow();