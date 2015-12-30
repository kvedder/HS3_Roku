' *********************************************************
' **  Roku Paragraph Demonstration App
' **  Support routines
' **  Feb 2010
' **  Copyright (c) 2010 Roku Inc. All Rights Reserved.
' *********************************************************

'***************************************************
'** Set up the screen in advance before its shown
'** Do any pre-display setup work here
'***************************************************


'********************************************************************
'** selecting close exits the application
'********************************************************************
Function getVideos(id)
    url="http://hs3.tv/api/list_games_by_client.php?id="+id
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    data2 = "{" + Chr(34) + "Videos" + Chr(34) + ":" + data + "}" 
    
   
    Return data2
End Function

Sub showImageCanvas(data)

json = ParseJSON(data)

'canvasItems = CreateObject("roArray", 1, false)
canvasItems = CreateObject("roArray", json.Videos.count(), false)

location = 100

for each video in json.Videos

    add = { 
            text: video.asset_title
            TargetRect:{x:location,y:location,w:400,h:300}
        }
        
canvasItems.push(add)
location = location + 100

end for


   canvas = CreateObject("roImageCanvas")
   port = CreateObject("roMessagePort")
   canvas.SetMessagePort(port)
   'Set opaque background
   canvas.SetLayer(0, {Color:"#FF000000", CompositionMode:"Source"})
   canvas.SetRequireAllImagesToDraw(true)
   canvas.SetLayer(1, canvasItems)
   canvas.Show()
   while(true)
       msg = wait(0,port)
       if type(msg) = "roImageCanvasEvent" then
           if (msg.isRemoteKeyPressed()) then
               i = msg.GetIndex()
               print "Key Pressed - " ; msg.GetIndex()
               if (i = 2) then
                   ' Up - Close the screen.
                   canvas.close()
               end if
           else if (msg.isScreenClosed()) then
               print "Closed"
               return
           end if
       end if
   end while
End Sub
