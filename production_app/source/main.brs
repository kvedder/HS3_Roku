Function getSchools()
    url="http://hs3.tv/api/list_schools.php"
    xfer=createobject("roURLTransfer")
    xfer.seturl(url)
    data=xfer.gettostring()
    data2 = "{" + Chr(34) + "Schools" + Chr(34) + ":" + data + "}" 
    
   
    Return data2
End Function

Function Main() as void
    'get school names
    data = getSchools()

    m.menuFunctions = [
        CreateLunchMenu,
        CreateBreakfastMenu
    ]
    screen = CreateObject("roListScreen")
    port = CreateObject("roMessagePort")
    screen.SetMessagePort(port)
    InitTheme()
    screen.SetHeader("Welcome to WOSN/HS3")
    screen.SetBreadcrumbText("Home", "Breakfast")
    contentList = InitContentList(data)
    screen.SetContent(contentList)
    screen.show()
    while (true)
        msg = wait(0, port)
        if (type(msg) = "roListScreenEvent")
            if (msg.isListItemFocused())
                screen.SetBreadcrumbText("Home", contentList[msg.GetIndex()].Title)
            else if (msg.isListItemSelected())
                CreateSchoolMenu(contentList[msg.GetIndex()].Title, contentList[msg.GetIndex()].ID)
                'CreateSchoolMenu(contentList[msg.GetIndex()].Title, contentList[msg.GetIndex()].ID)
            endif      
        endif
    end while
End Function

Function InitTheme() as void
    app = CreateObject("roAppManager")
    
    listItemHighlight           = "#FFFFFF"
    listItemText                = "#707070"
    brandingBlue               = "#707070"
    backgroundColor             = "#e0e0e0"
    theme = {
        BackgroundColor: backgroundColor
        OverhangSliceHD: "pkg:/images/Overhang_Slice_HD.png"
        OverhangSliceSD: "pkg:/images/Overhang_Slice_HD.png"
        OverhangLogoHD: "pkg:/images/hs3_logo.png"
        OverhangLogoSD: "pkg:/images/hs3_logo.png"
        OverhangOffsetSD_X: "45"
        OverhangOffsetSD_Y: "15"
        OverhangOffsetHD_X: "45"
        OverhangOffsetHD_Y: "15"
        BreadcrumbTextLeft: brandingBlue
        BreadcrumbTextRight: "#E1DFE0"
        BreadcrumbDelimiter: brandingBlue
        
        ListItemText: listItemText
        ListItemHighlightText: listItemHighlight
        ListScreenDescriptionText: listItemText
        ListItemHighlightHD: "pkg:/images/select_bkgnd.png"
        ListItemHighlightSD: "pkg:/images/select_bkgnd.png"
        CounterTextLeft: brandingBlue
        CounterSeparator: brandingBlue
        GridScreenBackgroundColor: backgroundColor
        GridScreenListNameColor: brandingBlue
        GridScreenDescriptionTitleColor: brandingBlue
        GridScreenLogoHD: "pkg://images/channel_diner_logo.png"
        GridScreenLogoSD: "pkg://images/channel_diner_logo.png"
        GridScreenOverhangHeightHD: "138"
        GridScreenOverhangHeightSD: "138"
        GridScreenOverhangSliceHD: "pkg:/images/Overhang_Slice_HD.png"
        GridScreenOverhangSliceSD: "pkg:/images/Overhang_Slice_HD.png"
        GridScreenLogoOffsetHD_X: "25"
        GridScreenLogoOffsetHD_Y: "15"
        GridScreenLogoOffsetSD_X: "25"
        GridScreenLogoOffsetSD_Y: "15"
    }
    app.SetTheme( theme )
End Function

Function InitContentList(data) as object
    
    'parse json data
    json = ParseJSON(data)

    'declare content list as empty to be filled by for each loop'
    contentList = []
     
    'set the ID for the first time'
     id = 1

    'for each for setting content list
    for each school in json.Schools



        add = { 
                Title: school.school_name
                ID: school.schoolid,
                SDSmallIconUrl: "pkg:/images/breakfast_small.png",
                HDSmallIconUrl: "pkg:/images/breakfast_small.png",
                HDBackgroundImageUrl: school.school_logo,
                SDBackgroundImageUrl: school.school_logo,            
                ShortDescriptionLine1: school.school_name,
                ShortDescriptionLine2: school.location
            }

        contentList.push(add)

        id = id + 1

    end for
 

    return contentList
End Function