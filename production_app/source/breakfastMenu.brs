Function CreateBreakfastMenu() as integer
    screen = CreateObject("roPosterScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    
    screen.SetBreadcrumbText("Breakfast", "Full Menu")

    screen.SetContentList(GetBreakfastMenuOptions())
    screen.SetFocusedListItem(4)
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isListItemSelected())
                ShowBreakfastItemDetails( msg.GetIndex() )
            endif
        endif
        
    end while
End Function

Function getVideos(id)
   
    url="http://hs3.tv/api/list_games_by_client.php?id="+id
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    data2 = "{" + Chr(34) + "Videos" + Chr(34) + ":" + data + "}" 
    
   
    Return data2
End Function

Function CreateSchoolMenu(schoolname, schoolid) as integer

    screen = CreateObject("roPosterScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    screen.SetListStyle("arced-16x9")
    
    screen.SetBreadcrumbText(schoolname, "Full Menu")

    'need to set the 43 to variable passed from previos screen
    screen.SetContentList(GetBreakfastMenuOptions(schoolid))
    screen.SetFocusedListItem(4)
    screen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roPosterScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isListItemSelected())
                ShowBreakfastItemDetails( msg.GetIndex() )
            endif
        endif
        
    end while
End Function

Function GetBreakfastMenuOptions(id) as object
    'make integer a string'
    'id2 = 43
    id= id.ToStr()

    'get list of school videos as JSON'
    data = getVideos(id)

    'parse JSON'
    json = ParseJSON(data)

    'declare empty array for video list'
    m.options = []

    'use foreach to populate array
    for each video in json.Videos

    'data = getVideoURL(id, video.kt_entry_id)
    streamURL = ParseJSON(data)

        add = { 
            
            ShortDescriptionLine1: video.asset_title
            ID: id
            EntryID: video.kt_entry_id
            Calories: "500"
            SDPosterURL: "http://video.wtlw.com/p/101/sp/10100/thumbnail/entry_id/"+video.kt_entry_id+"/width/285/height/145"
            HDPosterURL: "http://video.wtlw.com/p/101/sp/10100/thumbnail/entry_id/"+video.kt_entry_id+"/width/385/height/218"
            streamURL: streamURL
            }
            
    m.options.push(add)
    
    end for
      
    return m.options
End Function

Function ShowBreakfastItemDetails(index as integer) as integer
    print "Selected Index: " + Stri(index)

    detailsScreen = CreateObject("roSpringboardScreen")
    port = CreateObject("roMessagePort")
    detailsScreen.SetMessagePort(port)
    detailsScreen.SetDescriptionStyle("generic")
    detailsScreen.SetBreadcrumbText("Breakfast", m.options[index].ShortDescriptionLine1)
    detailsScreen.SetStaticRatingEnabled(false)
    vUrl = getVideoURL(m.options[index].ID, m.options[index].EntryID)
    streamURL = ParseJSON(vUrl)

    accessStatus = checkAccess()
  
    details = {
        id: m.options[index].ID
        entryId: m.options[index].EntryID
        HDPosterUrl: m.options[index].HDPosterURL
        SDPosterUrl: m.options[index].SDPosterURL
        
        Description: accessStatus
        LabelAttrs: ["Price:", "Calories per Serving:"]
        LabelVals: [m.options[index].Price, m.options[index].Calories]
        StreamURL: streamURL
        accessStatus: accessStatus
    }
    detailsScreen.SetContent(details)
    detailsScreen.AddButton(1, "Play This Game")
    detailsScreen.AddButton(2, "Report to FDA")
    detailsScreen.show()
    
    while (true)
        msg = wait(0, port)
        if type(msg) = "roSpringboardScreenEvent"
            if (msg.isScreenClosed())
                return -1
            else if (msg.isButtonPressed())
                DetailsScreenButtonClicked( msg.GetIndex(), details )
            endif
        endif
    end while
End Function

Function DetailsScreenButtonClicked(index as integer, details) as void
    dialog = CreateObject("roOneLineDialog")
    if (index = 1)
        'dialog.SetTitle("Placing Order")
        if (details.accessStatus = "true")
        displayVideo(details)
        else
        dialog.SetTitle("Sorry, you have  not purchased this game yet. Please go to hs3.tv to subscribe, or purchase this individual game.")
        end if
    else if (index = 2)
        dialog.SetTitle("Reporting Food to FDA")
    endif
    dialog.ShowBusyAnimation()
    dialog.show()
    
    Sleep(4000)
End Function

Function getVideoURL(ID, entryId)
   
    url="http://hs3.tv/api/get_play_urls.php?id="+ID+"&entryid="+entryId
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.getToString()
    
      
    Return data
End Function

Function checkAccess ()
    url="http://hs3.tv/api/check_access.php"
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.getToString()
    
    'validate is access granted is true or false
    if (data = "1")
    return "true"
    else if (data = "0") 
    return "false"
    endif     
    
End Function

'*************************************************************
'** displayVideo()
'*************************************************************

Function displayVideo(details)
    
    print "Displaying video: "
    p = CreateObject("roMessagePort")
    video = CreateObject("roVideoScreen")
    video.setMessagePort(p)

    'bitrates  = [0]          ' 0 = no dots, adaptive bitrate
    'bitrates  = [348]    ' <500 Kbps = 1 dot
    'bitrates  = [664]    ' <800 Kbps = 2 dots
    'bitrates  = [996]    ' <1.1Mbps  = 3 dots
    'bitrates  = [2048]    ' >=1.1Mbps = 4 dots
    bitrates  = [5000]    

    'Swap the commented values below to play different video clips...
    urls = details.StreamURL
    qualities = ["HD"]
    StreamFormat = "mp4"
    title = details.Description
   

    'urls = ["http://video.ted.com/talks/podcast/DanGilbert_2004_480.mp4"]
    'qualities = ["HD"]
    'StreamFormat = "mp4"
    'title = "Dan Gilbert asks, Why are we happy?"

    ' Apple's HLS test stream
    'urls = ["http://devimages.apple.com/iphone/samples/bipbop/bipbopall.m3u8"]
    'qualities = ["SD"]
    'streamformat = "hls"
    'title = "Apple BipBop Test Stream"


       
    videoclip = CreateObject("roAssociativeArray")
    videoclip.StreamBitrates = bitrates
    videoclip.StreamUrls = urls
    videoclip.StreamQualities = qualities
    videoclip.StreamFormat = StreamFormat
    videoclip.Title = title

    
    video.SetContent(videoclip)
    video.show()

    lastSavedPos   = 0
    statusInterval = 10 'position must change by more than this number of seconds before saving

    while true
        msg = wait(0, video.GetMessagePort())
        if type(msg) = "roVideoScreenEvent"
            if msg.isScreenClosed() then 'ScreenClosed event
                'print "Closing video screen"
                exit while
            else if msg.isPlaybackPosition() then
                nowpos = msg.GetIndex()
                if nowpos > 10000
                    
                end if
                if nowpos > 0
                    if abs(nowpos - lastSavedPos) > statusInterval
                        lastSavedPos = nowpos
                    end if
                end if
            else if msg.isRequestFailed()
                print "play failed: "; msg.GetMessage()
            else
                print "Unknown event: "; msg.GetType(); " msg: "; msg.GetMessage()
            endif
        end if
    end while
End Function
