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
  "type" : "document",
  "data" : {
	"viewPosition" : {
	  "px" : 0
	},
	"height" : {
	  "px" : 2368
	},
	"width" : {
	  "px" : 1512
	},
	"children" : [
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "frameless",
		  "height" : {
			"px" : 265.5
		  },
		  "position" : {
			"x" : {
			  "px" : 662.5
			},
			"y" : {
			  "px" : 59.5
			},
			"posInViewStack" : 4
		  },
		  "width" : {
			"px" : 362.5
		  },
		  "children" : [
			{
			  "position" : 0,
			  "active" : true,
			  "contentType" : "note",
			  "id" : "7749BDE6-61E3-495F-BF92-DB68B631B53E",
			  "contentState" : "empty"
			}
		  ]
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "previousDisplayState" : {
			"expandCollapseDirection" : "leftToRight",
			"state" : "minimised"
		  },
		  "position" : {
			"y" : {
			  "px" : 407
			},
			"posInViewStack" : 5,
			"x" : {
			  "px" : 294
			}
		  },
		  "state" : "expanded",
		  "name" : "Simone Weil",
		  "id" : "C928D41B-64AF-4C32-8AF7-AE3FFD3B589E",
		  "width" : {
			"px" : 1186
		  },
		  "children" : [
			{
			  "active" : true,
			  "id" : "804AECC8-4217-4775-8795-573C6FC39C52",
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "position" : 0
			},
			{
			  "contentType" : "web",
			  "contentState" : "loading",
			  "position" : 1,
			  "active" : false,
			  "id" : "D4AE3873-88D7-435C-A374-736BE10A1334"
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "4B5F2AD0-825C-44D2-95B6-7F7D40DF140C",
			  "position" : 2,
			  "active" : false
			}
		  ],
		  "height" : {
			"px" : 790
		  }
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "minimised",
		  "width" : {
			"px" : 280
		  },
		  "name" : "Intro to Attention Research",
		  "height" : {
			"px" : 344
		  },
		  "position" : {
			"posInViewStack" : 2,
			"x" : {
			  "px" : 29.5
			},
			"y" : {
			  "px" : 45
			}
		  },
		  "id" : "3D30D97A-F76E-4F08-870A-91701C7E9966",
		  "children" : [
			{
			  "active" : true,
			  "contentType" : "web",
			  "position" : 0,
			  "contentState" : "loaded",
			  "id" : "29880BD7-959B-4A6B-994D-6ADE0EA5D0ED"
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "3C2EAF73-078F-4A1C-9A18-02E66571E1DC",
			  "position" : 1,
			  "active" : false
			},
			{
			  "active" : false,
			  "contentType" : "web",
			  "position" : 2,
			  "contentState" : "loaded",
			  "id" : "4D0224DE-09F2-4604-9DA7-DCCFB6592461"
			},
			{
			  "contentType" : "web",
			  "position" : 3,
			  "active" : false,
			  "id" : "F91CD41D-88A2-4E65-84E4-5D11C7AD9506",
			  "contentState" : "loaded"
			},
			{
			  "position" : 4,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "60860BC4-098E-46F0-ADA0-218173787EA4",
			  "active" : false
			},
			{
			  "id" : "D99FD174-5AE7-433E-8956-C85644EDC876",
			  "contentState" : "loaded",
			  "active" : false,
			  "position" : 5,
			  "contentType" : "web"
			},
			{
			  "id" : "D609A82C-4F49-4A2B-BB57-3F2B523DA38A",
			  "contentState" : "loaded",
			  "active" : false,
			  "position" : 6,
			  "contentType" : "web"
			}
		  ]
		}
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "children" : [
			{
			  "contentState" : "empty",
			  "active" : true,
			  "id" : "6E68BBC0-5B7A-47EE-AB9D-673F5EAA83D9",
			  "position" : 0,
			  "contentType" : "note"
			}
		  ],
		  "state" : "frameless",
		  "width" : {
			"px" : 437
		  },
		  "height" : {
			"px" : 375
		  },
		  "position" : {
			"x" : {
			  "px" : 1040
			},
			"posInViewStack" : 1,
			"y" : {
			  "px" : 60.5
			}
		  }
		}
	  },
	  {
		"data" : {
		  "children" : [
			{
			  "id" : "7C0650C0-2F67-4A7C-BC5F-A3D122878EDD",
			  "active" : false,
			  "position" : 0,
			  "contentState" : "loaded",
			  "contentType" : "web"
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "position" : 1,
			  "id" : "50E4E6FC-978E-4C9F-BF16-F3A556BEED43"
			},
			{
			  "position" : 2,
			  "active" : false,
			  "id" : "AEBDFD03-BDDE-4B9B-834F-6F16680438A1",
			  "contentType" : "web",
			  "contentState" : "loaded"
			},
			{
			  "id" : "D28995F8-E85E-4173-9272-6FA363922FCC",
			  "active" : false,
			  "position" : 3,
			  "contentState" : "loaded",
			  "contentType" : "web"
			}
		  ],
		  "height" : {
			"px" : 215
		  },
		  "name" : "William James",
		  "state" : "minimised",
		  "width" : {
			"px" : 280
		  },
		  "id" : "4CCEA0C4-4DE2-46F0-B024-22BE7473CC4D",
		  "position" : {
			"posInViewStack" : 3,
			"x" : {
			  "px" : 323
			},
			"y" : {
			  "px" : 45
			}
		  }
		},
		"type" : "contentFrame"
	  }
	],
	"id" : "2F0DE38D-8215-4DB1-95A0-6F04C2ECE821"
  }
}');
"""
}
