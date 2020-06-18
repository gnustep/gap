include $(GNUSTEP_MAKEFILES)/common.make

APP_NAME = HelpViewer
HelpViewer_OBJC_FILES = main.m mainWindowController.m Label.m \
			Controller.m FigureCell.m Legend.m\
			HandlerStructureXLP.m \
			TextFormatterXLP.m \
			BrowserCell.m NoteCell.m \
			ModNSString.m BRCell.m Page.m Section.m # Parser.m # Table.m BRCell.m ViewCell.m TextViewCell.m 
HelpViewer_RESOURCE_FILES = Icons/Index.tiff Icons/Back.tiff Icons/Search.tiff Icons/Bookshelf.tiff Icons/HelpViewer.tiff \
			Icons/helpviewer-200.tiff Icons/Logo.tiff \
			Icons/part.tiff Icons/chapter.tiff Icons/notloaded.tiff Icons/errorloading.tiff \
			Icons/note.png Icons/caution.png Icons/listing.png Icons/information.png \
			Icons/Point.tiff Icons/Point2.tiff Icons/Icon-hlpd.tiff\
			Gorm/Main.gorm HelpViewer.help
HelpViewer_MAIN_MODEL_FILE = Main.gorm
#HelpViewer_PRINCIPAL_CLASS = NSApplication

HelpViewer_LANGUAGES = English # French

#HelpViewer_LOCALIZED_RESOURCE_FILES = Logo.tiff helpviewer-200.tiff $(APP_NAME).xlp

include $(GNUSTEP_MAKEFILES)/application.make
