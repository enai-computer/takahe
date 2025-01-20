//
//  PregenLearnEnai.swift
//  Enai
//
//  Created by Patrick Lukas on 10/12/24.
//

class PregenLearnEnai{
	
	let contentTable_sql = """
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D84C8F1A-DFEA-4146-B694-138013B5BC45', 'Welcome to Enai', 'web', '1733780653.51731', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('4B98062A-75D0-428A-B10E-A88209CC406E', 'Information overload - Wikipedia', 'web', '1733780561.53975', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('97FD9B7A-12B4-4069-A31F-97F3391601C7', 'Capacity theory - Wikipedia', 'web', '1733780561.54083', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('0F64AA7B-6548-4B08-A6AA-F122B16B7998', 'Alexander Technique for Digital Wellbeing ~ mindful.technology', 'web', '1733840294.85922', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('3E66249D-497C-4355-A307-9A0DD319917E', 'Welcome to Enai! ', 'note', '1732801271.17601', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('BA9BD9C1-BFDA-47BF-AAF1-0BF0A49952E6', 'Create a space for your biggest project! ', 'note', '1732801313.95069', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('9A13F716-8A25-4F85-9947-C2430EBE63C4', 'It takes 23 mins to recover after an interruption', 'web', '1732801481.17287', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('0BB22396-DEB1-490B-9420-AFB2D9793ED2', 'Calendly - Curran Dwyer', 'web', '1733780503.51305', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('B825A325-B416-4EAE-9FC5-ED165D45CD44', 'Enai saves the link when you drag an image on the canvas. Click on images to learn about them…', 'note', '1733777983.53148', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('2AF28C7D-16A8-466C-A012-76F90B81D210', 'To start using Enai:', 'note', '1733777030.83827', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('BC23ECA0-151E-4B2C-903A-142BDAB97EFC', 'The Architecture of Focus - by Welf von Hören - Monastic', 'web', '1733777923.53209', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D0D016CE-BB3C-4856-9566-7D009EFB3475', '<— ', 'note', '1733782753.49859', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('EC5B8AD8-E787-4247-B997-1575D4E4AB6C', 'Transcendental Meditation Technique – Official Website', 'web', '1733851671.59509', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('90942B72-DA54-4B67-BA93-D680A2356A5C', 'Walden - Meditation Essentials', 'web', '1733851671.59623', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('9862D836-145B-4EF6-B630-A1C4B2435C67', 'tommy-visual-language-exploration-91.jpg | Are.na', 'web', '1733851671.59444', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('0FBEBAF9-4796-40B2-8108-356E6E123CC7', 'Tetragrammaton', 'web', '1733851671.59675', NULL, '1', NULL);
"""
	
	let doc_content_sql = """
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'D84C8F1A-DFEA-4146-B694-138013B5BC45');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '4B98062A-75D0-428A-B10E-A88209CC406E');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '97FD9B7A-12B4-4069-A31F-97F3391601C7');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '0F64AA7B-6548-4B08-A6AA-F122B16B7998');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '3E66249D-497C-4355-A307-9A0DD319917E');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'BA9BD9C1-BFDA-47BF-AAF1-0BF0A49952E6');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '9A13F716-8A25-4F85-9947-C2430EBE63C4');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '0BB22396-DEB1-490B-9420-AFB2D9793ED2');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'B825A325-B416-4EAE-9FC5-ED165D45CD44');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '2AF28C7D-16A8-466C-A012-76F90B81D210');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'BC23ECA0-151E-4B2C-903A-142BDAB97EFC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'D0D016CE-BB3C-4856-9566-7D009EFB3475');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', 'EC5B8AD8-E787-4247-B997-1575D4E4AB6C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '90942B72-DA54-4B67-BA93-D680A2356A5C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '9862D836-145B-4EF6-B630-A1C4B2435C67');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('00000000-0000-0000-0000-000000000001', '0FBEBAF9-4796-40B2-8108-356E6E123CC7');
"""
	
	let cached_web_sql = """
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D84C8F1A-DFEA-4146-B694-138013B5BC45', 'https://enai.notion.site/Welcome-to-Enai-2fcd5d82f9d54b98880913b0c0c61226', '1719327280.11507', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('4B98062A-75D0-428A-B10E-A88209CC406E', 'https://en.wikipedia.org/wiki/Information_overload', '1719327280.13873', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('97FD9B7A-12B4-4069-A31F-97F3391601C7', 'https://en.wikipedia.org/wiki/Capacity_theory', '1719327280.14038', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('0F64AA7B-6548-4B08-A6AA-F122B16B7998', 'https://mindful.technology/alexander-technique-for-digital-wellbeing/', '1733840294.86069', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('9A13F716-8A25-4F85-9947-C2430EBE63C4', 'https://addyo.substack.com/p/it-takes-23-mins-to-recover-after', '1732801481.17445', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('0BB22396-DEB1-490B-9420-AFB2D9793ED2', 'https://calendly.com/curran7', '1732801511.16318', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('BC23ECA0-151E-4B2C-903A-142BDAB97EFC', 'https://monastic.substack.com/p/the-architecture-of-focus', '1733777923.53302', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('EC5B8AD8-E787-4247-B997-1575D4E4AB6C', 'https://www.tm.org/homepage-1?va-red=MTQyODk6MTk3MjY', '1733851671.59562', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('90942B72-DA54-4B67-BA93-D680A2356A5C', 'https://walden.us/', '1733840504.85933', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('9862D836-145B-4EF6-B630-A1C4B2435C67', 'https://www.are.na/block/21554809', '1733840984.85409', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('0FBEBAF9-4796-40B2-8108-356E6E123CC7', 'https://www.tetragrammaton.com/', '1733840984.85623', NULL, NULL);
"""
	
	let user_notes = """
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('3E66249D-497C-4355-A307-9A0DD319917E', '1733778572.11706', 'Welcome to Enai! 

Our aspiration is to be your new general purpose interface. If you squint, you might see a future of computing that supports your intent, attention, and time.

Right now, Enai is a seedling. We are counting on you to help us grow Enai into something beautiful and helpful for you. You can email us at any time: curran@enai.io (product) and patrick@enai.io (technical)');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('BA9BD9C1-BFDA-47BF-AAF1-0BF0A49952E6', '1732801421.16797', 'Create a space for your biggest project! 

1. press ⌘ . 
(command and period keys at the same time)

2. type the project name');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('B825A325-B416-4EAE-9FC5-ED165D45CD44', '1733777983.53234', 'Enai saves the link when you drag an image on the canvas. Click on images to learn about them…');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('2AF28C7D-16A8-466C-A012-76F90B81D210', '1733841921.18705', 'To start using Enai:
- Create a space for your biggest project
- Focus on it for a while
- Don’t close anything when you’re done
- Instead, press ⌘ .
- You might want to take a breath - feature request?
- For now, just switch to a new space');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('D0D016CE-BB3C-4856-9566-7D009EFB3475', '1733836869.29519', '<— 

Schedule a meeting with a co-founder if you have any feedback :)

calendly.com/curran7');
"""
	
	let doc_table = """
INSERT INTO "document" ("id", "name", "owner", "shared", "created_at", "updated_at", "updated_by", "document") VALUES ('00000000-0000-0000-0000-000000000001', 'Learn to use Enai', NULL, '0', '1733861724.64249', '1733861724.64249', NULL, '{
  "data" : {
	"height" : {
	  "px" : 2880
	},
	"viewPosition" : {
	  "px" : 0
	},
	"id" : "00000000-0000-0000-0000-000000000001",
	"width" : {
	  "px" : 2560
	},
	"children" : [
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"posInViewStack" : 11,
			"x" : {
			  "px" : 139.5
			},
			"y" : {
			  "px" : 994.5
			}
		  },
		  "width" : {
			"px" : 1190.5
		  },
		  "name" : "Things we like",
		  "state" : "expanded",
		  "height" : {
			"px" : 895
		  },
		  "children" : [
			{
			  "id" : "9862D836-145B-4EF6-B630-A1C4B2435C67",
			  "contentState" : "loaded",
			  "position" : 0,
			  "active" : false,
			  "contentType" : "web"
			},
			{
			  "id" : "EC5B8AD8-E787-4247-B997-1575D4E4AB6C",
			  "position" : 1,
			  "contentState" : "loaded",
			  "active" : false,
			  "contentType" : "web"
			},
			{
			  "active" : false,
			  "id" : "90942B72-DA54-4B67-BA93-D680A2356A5C",
			  "contentType" : "web",
			  "position" : 2,
			  "contentState" : "loaded"
			},
			{
			  "id" : "0FBEBAF9-4796-40B2-8108-356E6E123CC7",
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "active" : true,
			  "position" : 3
			}
		  ],
		  "id" : "C9F7CD67-076A-4134-B69D-311DC6B40BDF"
		}
	  },
	  {
		"data" : {
		  "position" : {
			"posInViewStack" : 8,
			"x" : {
			  "px" : 768.5
			},
			"y" : {
			  "px" : 175
			}
		  },
		  "height" : {
			"px" : 57
		  },
		  "state" : "sectionTitle",
		  "children" : [

		  ],
		  "name" : "Mindful Computing",
		  "id" : "6AB8AFAB-E9C9-4520-88DA-EF8511A59C9E",
		  "width" : {
			"px" : 714
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"x" : {
			  "px" : 24
			},
			"y" : {
			  "px" : 175.5
			},
			"posInViewStack" : 7
		  },
		  "width" : {
			"px" : 714
		  },
		  "state" : "sectionTitle",
		  "name" : "How to use Enai",
		  "id" : "27E69624-6335-4A2D-A30F-A6C1CA761F6E",
		  "children" : [

		  ],
		  "height" : {
			"px" : 57
		  }
		}
	  },
	  {
		"data" : {
		  "position" : {
			"x" : {
			  "px" : 335
			},
			"posInViewStack" : 9,
			"y" : {
			  "px" : 605.5
			}
		  },
		  "height" : {
			"px" : 200
		  },
		  "width" : {
			"px" : 200
		  },
		  "state" : "frameless",
		  "children" : [
			{
			  "id" : "D0D016CE-BB3C-4856-9566-7D009EFB3475",
			  "position" : 0,
			  "active" : true,
			  "contentState" : "blue",
			  "contentType" : "sticky"
			}
		  ]
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "frameless",
		  "height" : {
			"px" : 262
		  },
		  "width" : {
			"px" : 393
		  },
		  "position" : {
			"x" : {
			  "px" : 1082.5
			},
			"posInViewStack" : 5,
			"y" : {
			  "px" : 240
			}
		  },
		  "children" : [
			{
			  "position" : 0,
			  "id" : "8FB53F87-D45C-431B-94D0-E89AF42694D7",
			  "contentType" : "img",
			  "contentState" : "empty",
			  "active" : true
			}
		  ]
		}
	  },
	  {
		"data" : {
		  "id" : "9AC595F8-F602-4447-8175-BA126815618E",
		  "state" : "minimised",
		  "previousDisplayState" : {
			"defaultWindowOrigin" : {
			  "x" : {
				"px" : 66.5
			  },
			  "y" : {
				"px" : 82
			  }
			},
			"minimisedOrigin" : {
			  "x" : {
				"px" : 30
			  },
			  "y" : {
				"px" : 514
			  }
			},
			"expandCollapseDirection" : "leftToRight",
			"state" : "expanded"
		  },
		  "position" : {
			"y" : {
			  "px" : 514
			},
			"posInViewStack" : 2,
			"x" : {
			  "px" : 30
			}
		  },
		  "width" : {
			"px" : 280
		  },
		  "height" : {
			"px" : 129
		  },
		  "children" : [
			{
			  "contentState" : "loaded",
			  "id" : "D84C8F1A-DFEA-4146-B694-138013B5BC45",
			  "active" : false,
			  "position" : 0,
			  "contentType" : "web"
			},
			{
			  "contentState" : "loaded",
			  "active" : true,
			  "position" : 1,
			  "contentType" : "web",
			  "id" : "0BB22396-DEB1-490B-9420-AFB2D9793ED2"
			}
		  ],
		  "name" : "Enai User Guides"
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"posInViewStack" : 6,
			"x" : {
			  "px" : 1143.5
			},
			"y" : {
			  "px" : 461.5
			}
		  },
		  "children" : [
			{
			  "active" : true,
			  "contentState" : "empty",
			  "contentType" : "note",
			  "position" : 0,
			  "id" : "B825A325-B416-4EAE-9FC5-ED165D45CD44"
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 324
		  },
		  "height" : {
			"px" : 85.5
		  }
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "position" : {
			"x" : {
			  "px" : 775.5
			},
			"y" : {
			  "px" : 651.5
			},
			"posInViewStack" : 3
		  },
		  "state" : "sectionTitle",
		  "height" : {
			"px" : 57
		  },
		  "width" : {
			"px" : 714
		  },
		  "id" : "6C104CF4-9D89-4523-8DA3-B118BBF32F67",
		  "name" : "What to do next in Enai",
		  "children" : [

		  ]
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "children" : [
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "4B98062A-75D0-428A-B10E-A88209CC406E",
			  "position" : 0
			},
			{
			  "contentType" : "web",
			  "id" : "97FD9B7A-12B4-4069-A31F-97F3391601C7",
			  "contentState" : "loaded",
			  "position" : 1,
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "active" : true,
			  "position" : 2,
			  "contentType" : "web",
			  "id" : "0F64AA7B-6548-4B08-A6AA-F122B16B7998"
			},
			{
			  "contentType" : "web",
			  "id" : "9A13F716-8A25-4F85-9947-C2430EBE63C4",
			  "contentState" : "loaded",
			  "active" : false,
			  "position" : 3
			},
			{
			  "position" : 4,
			  "id" : "BC23ECA0-151E-4B2C-903A-142BDAB97EFC",
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false
			}
		  ],
		  "position" : {
			"y" : {
			  "px" : 240.5
			},
			"posInViewStack" : 10,
			"x" : {
			  "px" : 779.5
			}
		  },
		  "previousDisplayState" : {
			"state" : "expanded",
			"defaultWindowOrigin" : {
			  "y" : {
				"px" : 52.5
			  },
			  "x" : {
				"px" : 87
			  }
			},
			"expandCollapseDirection" : "leftToRight",
			"minimisedOrigin" : {
			  "x" : {
				"px" : 779.5
			  },
			  "y" : {
				"px" : 240.5
			  }
			}
		  },
		  "width" : {
			"px" : 280
		  },
		  "state" : "minimised",
		  "id" : "75415DB4-FC7F-4DED-B56B-FC8A6912FF3A",
		  "height" : {
			"px" : 258
		  },
		  "name" : "Care for your attention"
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 470.5
		  },
		  "height" : {
			"px" : 198.5
		  },
		  "position" : {
			"y" : {
			  "px" : 722
			},
			"posInViewStack" : 12,
			"x" : {
			  "px" : 1005.5
			}
		  },
		  "children" : [
			{
			  "contentState" : "empty",
			  "contentType" : "note",
			  "id" : "2AF28C7D-16A8-466C-A012-76F90B81D210",
			  "active" : true,
			  "position" : 0
			}
		  ],
		  "state" : "frameless"
		}
	  },
	  {
		"data" : {
		  "width" : {
			"px" : 200.5
		  },
		  "children" : [
			{
			  "active" : true,
			  "id" : "BA9BD9C1-BFDA-47BF-AAF1-0BF0A49952E6",
			  "contentState" : "yellow",
			  "contentType" : "sticky",
			  "position" : 0
			}
		  ],
		  "position" : {
			"x" : {
			  "px" : 778.5
			},
			"y" : {
			  "px" : 723
			},
			"posInViewStack" : 1
		  },
		  "height" : {
			"px" : 200
		  },
		  "state" : "frameless"
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "position" : {
			"posInViewStack" : 4,
			"y" : {
			  "px" : 260.5
			},
			"x" : {
			  "px" : 27.5
			}
		  },
		  "children" : [
			{
			  "contentState" : "empty",
			  "position" : 0,
			  "contentType" : "note",
			  "active" : true,
			  "id" : "3E66249D-497C-4355-A307-9A0DD319917E"
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 596
		  },
		  "height" : {
			"px" : 192.5
		  }
		},
		"type" : "contentFrame"
	  }
	]
  },
  "type" : "document"
}');
"""
}
