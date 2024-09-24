//
//  PregenIntent.swift
//  ni
//
//  Created by Patrick Lukas on 25/6/24.
//

import Foundation

class PregenIntent{
	
	let intent_content_sql = """
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('29880BD7-959B-4A6B-994D-6ADE0EA5D0ED', 'CABINET / Hummingbird Futures', 'web', '1719337380.62598', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('3C2EAF73-078F-4A1C-9A18-02E66571E1DC', 'Attention (Stanford Encyclopedia of Philosophy)', 'web', '1719337380.62674', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('4B5F2AD0-825C-44D2-95B6-7F7D40DF140C', 'Perplexity', 'web', '1719337380.62405', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('4D0224DE-09F2-4604-9DA7-DCCFB6592461', 'Attention - Wikipedia', 'web', '1719337380.62768', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('50E4E6FC-978E-4C9F-BF16-F3A556BEED43', 'Attention - Wikipedia', 'web', '1719337380.61957', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('60860BC4-098E-46F0-ADA0-218173787EA4', 'Daniel Kahneman - Wikipedia', 'web', '1719337380.62924', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('7749BDE6-61E3-495F-BF92-DB68B631B53E', 'Focalization, concentration, of consciousness are of its essence. It implies withdrawal from some things in order to deal effectively with others, and is a condition which has a real opposite in the confused, dazed, scatterbrained state which in French is called distraction, and Zerstreutheit in German.', 'note', '1719337380.62494', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('7C0650C0-2F67-4A7C-BC5F-A3D122878EDD', 'What attention is. The priority structure account - PMC', 'web', '1719337380.61804', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('804AECC8-4217-4775-8795-573C6FC39C52', 'Notion – The all-in-one workspace for your notes, tasks, wikis, and databases.', 'web', '1719337380.62221', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('AEBDFD03-BDDE-4B9B-834F-6F16680438A1', 'Classics in the History of Psychology -- James (1890) Chapter 26', 'web', '1719337380.62048', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D28995F8-E85E-4173-9272-6FA363922FCC', 'Pioneering Psychologist William James on Attention, Multitasking, and the Mental Habit That Sets Great Minds Apart – The Marginalian', 'web', '1719337380.62142', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D4AE3873-88D7-435C-A374-736BE10A1334', 'Simone Weil’s Radical Conception of Attention ‹ Literary Hub', 'web', '1719337380.62324', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D609A82C-4F49-4A2B-BB57-3F2B523DA38A', 'Donald Broadbent - Wikipedia', 'web', '1719337380.63061', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('D99FD174-5AE7-433E-8956-C85644EDC876', 'Inattentional blindness - Wikipedia', 'web', '1719337380.62992', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('F91CD41D-88A2-4E65-84E4-5D11C7AD9506', 'attention and effort - Google Search', 'web', '1719337380.62838', '', '1', '');
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('6E68BBC0-5B7A-47EE-AB9D-673F5EAA83D9', '', 'note', '1719337380.63149', '', '1', '');
"""
	
	let intent_note_sql = """
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('6E68BBC0-5B7A-47EE-AB9D-673F5EAA83D9', '1719337380.63181', 'Donald Broadbent’s distinctive contribution to the overthrow of behaviourism was to show how the move from behavioural data to the postulation of a particular cognitive architecture could be disciplined by the then-new strategy of importing into psychology the intellectual resources used in thinking about information technology. The year in which Broadbent’s book was published was an important year for the development of such technologies, being the year in which (inter alia) the integrated circuit chip was invented (see Mole, 2012). It was also the year in which Subscriber Trunk Dialling was introduced to UK telephone exchanges. The technology of the telephone exchange was what most naturally suggested itself as a metaphor for attention at the time when Broadbent was writing.');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('7749BDE6-61E3-495F-BF92-DB68B631B53E', '1719337380.62529', 'Focalization, concentration, of consciousness are of its essence. It implies withdrawal from some things in order to deal effectively with others, and is a condition which has a real opposite in the confused, dazed, scatterbrained state which in French is called distraction, and Zerstreutheit in German.

"By Charles Bonnet the Mind is allowed to have a distinct notion of six objects at once; by Abraham Tucker the number is limited to four; while Destutt Tracy again amplifies it to six. The opinion of the first and last of these philosophers" [continues Sir Wm. Hamilton] "seems to me correct. You can easily make the experiments for yourselves, but you must beware of grouping the objects into classes. If you throw a handful of marbles on the floor, you will find it difficult to view at once more than six, or seven at most, without confusion; but if you group them into twos, or threes, or fives, you can comprehend as many groups as you can units; because the mind considers these groups only as units - it views them as wholes, and throws their parts out of consideration."[4]');
"""
	let intent_doc_content_sql = """
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '29880BD7-959B-4A6B-994D-6ADE0EA5D0ED');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '3C2EAF73-078F-4A1C-9A18-02E66571E1DC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '4B5F2AD0-825C-44D2-95B6-7F7D40DF140C');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '4D0224DE-09F2-4604-9DA7-DCCFB6592461');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '50E4E6FC-978E-4C9F-BF16-F3A556BEED43');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '60860BC4-098E-46F0-ADA0-218173787EA4');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '7C0650C0-2F67-4A7C-BC5F-A3D122878EDD');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '804AECC8-4217-4775-8795-573C6FC39C52');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'AEBDFD03-BDDE-4B9B-834F-6F16680438A1');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'D28995F8-E85E-4173-9272-6FA363922FCC');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'D4AE3873-88D7-435C-A374-736BE10A1334');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'D609A82C-4F49-4A2B-BB57-3F2B523DA38A');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'D99FD174-5AE7-433E-8956-C85644EDC876');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'F91CD41D-88A2-4E65-84E4-5D11C7AD9506');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', '6E68BBC0-5B7A-47EE-AB9D-673F5EAA83D9');
"""
	
	let intent_cached_web_sql = """
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('29880BD7-959B-4A6B-994D-6ADE0EA5D0ED', 'https://www.cabinetmagazine.org/issues/13/rosenberg2.php', '1719337106.93585', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('3C2EAF73-078F-4A1C-9A18-02E66571E1DC', 'https://plato.stanford.edu/entries/attention/#VolAct', '1719337106.93816', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('4B5F2AD0-825C-44D2-95B6-7F7D40DF140C', 'https://www.perplexity.ai/', '1719337106.95885', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('4D0224DE-09F2-4604-9DA7-DCCFB6592461', 'https://en.wikipedia.org/wiki/Attention#Multitasking_and_divided_attention', '1719337106.94014', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('50E4E6FC-978E-4C9F-BF16-F3A556BEED43', 'https://en.wikipedia.org/wiki/Attention#:~:text=William%20James%20(1890)%20wrote%20that,objects%20or%20trains%20of%20thought.', '1719337106.95126', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('60860BC4-098E-46F0-ADA0-218173787EA4', 'https://en.wikipedia.org/wiki/Daniel_Kahneman#Cognitive_psychology', '1719337106.9439', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('7C0650C0-2F67-4A7C-BC5F-A3D122878EDD', 'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC10078238/', '1719337106.94969', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('804AECC8-4217-4775-8795-573C6FC39C52', 'https://enai.notion.site/Attention-2dcf8802ad854667ab14d942f4e4215e', '1719337106.95607', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('AEBDFD03-BDDE-4B9B-834F-6F16680438A1', 'https://psychclassics.yorku.ca/James/Principles/prin26.htm', '1719337106.95278', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D28995F8-E85E-4173-9272-6FA363922FCC', 'https://www.themarginalian.org/2016/03/25/william-james-attention/', '1719337106.95459', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D4AE3873-88D7-435C-A374-736BE10A1334', 'https://lithub.com/simone-weils-radical-conception-of-attention/', '1719337106.9575', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D609A82C-4F49-4A2B-BB57-3F2B523DA38A', 'https://en.wikipedia.org/wiki/Donald_Broadbent', '1719337106.94794', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('D99FD174-5AE7-433E-8956-C85644EDC876', 'https://en.wikipedia.org/wiki/Inattentional_blindness', '1719337106.94575', '', '');
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('F91CD41D-88A2-4E65-84E4-5D11C7AD9506', 'https://www.google.com/search?q=attention%20and%20effort#vhid=786B4JURgFx6YM&vssid=l', '1719337106.94207', '', '');
"""
	
	let intent_doc_table = """
INSERT INTO "document" ("id", "name", "owner", "shared", "created_at", "updated_at", "updated_by", "document") VALUES ('2F0DE38D-8215-4DB1-95A0-6F04C2ECE821', 'Intent, attention, and mindfulness', '', '0', '1719337106.93204', '1719337106.93204', '', '{
  "data" : {
	"viewPosition" : {
	  "px" : 0
	},
	"children" : [
	  {
		"data" : {
		  "width" : {
			"px" : 1351.5
		  },
		  "children" : [
			{
			  "contentType" : "web",
			  "active" : true,
			  "position" : 0,
			  "contentState" : "loaded",
			  "id" : "29880BD7-959B-4A6B-994D-6ADE0EA5D0ED"
			},
			{
			  "active" : false,
			  "contentType" : "web",
			  "id" : "3C2EAF73-078F-4A1C-9A18-02E66571E1DC",
			  "position" : 1,
			  "contentState" : "loaded"
			},
			{
			  "contentType" : "web",
			  "position" : 2,
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "4D0224DE-09F2-4604-9DA7-DCCFB6592461"
			},
			{
			  "active" : false,
			  "contentType" : "web",
			  "position" : 3,
			  "contentState" : "loaded",
			  "id" : "F91CD41D-88A2-4E65-84E4-5D11C7AD9506"
			},
			{
			  "id" : "60860BC4-098E-46F0-ADA0-218173787EA4",
			  "active" : false,
			  "contentState" : "loaded",
			  "contentType" : "web",
			  "position" : 4
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "D99FD174-5AE7-433E-8956-C85644EDC876",
			  "position" : 5
			},
			{
			  "id" : "D609A82C-4F49-4A2B-BB57-3F2B523DA38A",
			  "contentState" : "loaded",
			  "position" : 6,
			  "contentType" : "web",
			  "active" : false
			}
		  ],
		  "name" : "Intro to Attention Research",
		  "state" : "expanded",
		  "position" : {
			"posInViewStack" : 27,
			"x" : {
			  "px" : 39
			},
			"y" : {
			  "px" : 45
			}
		  },
		  "height" : {
			"px" : 773
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "position" : {
			"x" : {
			  "px" : 2250.5
			},
			"posInViewStack" : 26,
			"y" : {
			  "px" : 96.5
			}
		  },
		  "name" : "William James",
		  "state" : "minimised",
		  "children" : [
			{
			  "active" : false,
			  "id" : "7C0650C0-2F67-4A7C-BC5F-A3D122878EDD",
			  "contentState" : "loaded",
			  "position" : 0,
			  "contentType" : "web"
			},
			{
			  "contentType" : "web",
			  "position" : 1,
			  "id" : "50E4E6FC-978E-4C9F-BF16-F3A556BEED43",
			  "contentState" : "loaded",
			  "active" : false
			},
			{
			  "contentState" : "loaded",
			  "id" : "AEBDFD03-BDDE-4B9B-834F-6F16680438A1",
			  "position" : 2,
			  "active" : false,
			  "contentType" : "web"
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "position" : 3,
			  "id" : "D28995F8-E85E-4173-9272-6FA363922FCC",
			  "active" : true
			}
		  ],
		  "height" : {
			"px" : 192
		  },
		  "width" : {
			"px" : 263
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"data" : {
		  "children" : [
			{
			  "contentType" : "web",
			  "position" : 0,
			  "contentState" : "loaded",
			  "active" : true,
			  "id" : "804AECC8-4217-4775-8795-573C6FC39C52"
			},
			{
			  "active" : false,
			  "position" : 1,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "D4AE3873-88D7-435C-A374-736BE10A1334"
			},
			{
			  "active" : false,
			  "position" : 2,
			  "contentState" : "loaded",
			  "id" : "4B5F2AD0-825C-44D2-95B6-7F7D40DF140C",
			  "contentType" : "web"
			}
		  ],
		  "name" : "Simone Weil",
		  "position" : {
			"posInViewStack" : 31,
			"y" : {
			  "px" : 411
			},
			"x" : {
			  "px" : 394
			}
		  },
		  "height" : {
			"px" : 820
		  },
		  "state" : "expanded",
		  "width" : {
			"px" : 1186
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "height" : {
			"px" : 265.5
		  },
		  "children" : [
			{
			  "contentType" : "note",
			  "contentState" : "empty",
			  "id" : "7749BDE6-61E3-495F-BF92-DB68B631B53E",
			  "active" : true,
			  "position" : 0
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 362.5
		  },
		  "position" : {
			"y" : {
			  "px" : 316.5
			},
			"x" : {
			  "px" : 2144
			},
			"posInViewStack" : 30
		  }
		}
	  },
	  {
		"data" : {
		  "state" : "frameless",
		  "width" : {
			"px" : 363
		  },
		  "height" : {
			"px" : 200
		  },
		  "children" : [
			{
			  "contentType" : "note",
			  "active" : true,
			  "contentState" : "empty",
			  "id" : "6E68BBC0-5B7A-47EE-AB9D-673F5EAA83D9",
			  "position" : 0
			}
		  ],
		  "position" : {
			"x" : {
			  "px" : 2144.5
			},
			"posInViewStack" : 28,
			"y" : {
			  "px" : 610
			}
		  }
		},
		"type" : "contentFrame"
	  }
	],
	"id" : "2F0DE38D-8215-4DB1-95A0-6F04C2ECE821",
	"height" : {
	  "px" : 2368
	},
	"width" : {
	  "px" : 2560
	}
  },
  "type" : "document"
}');
"""
}
