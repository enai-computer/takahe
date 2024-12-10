//
//  PregenIdeas.swift
//  Enai
//
//  Created by Patrick Lukas on 10/12/24.
//

class PregenIdeas{
	
	let contentTable_sql = """
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('9D20C4C6-0B65-4D24-BC07-599E3A8BCA70', '', 'note', '1733778973.53342', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('9FE2BC42-709B-4D01-9385-5B578E3CD0B7', '', 'note', '1733779363.5115', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('8E242BBE-6636-4CAB-AA8B-3191A8549621', 'Attention Span - GLORIA MARK, PhD', 'web', '1733779693.51359', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('AC5EF438-4A7E-4AAF-85F4-B1A62B9D3064', 'Desktop metaphor - Wikipedia', 'web', '1733839814.85664', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('0976D8F8-95EC-4196-8C9C-E93459690372', 'Augmenting Human Intellect: A Conceptual Framework - 1962 (AUGMENT,3906,)-Doug Engelbart Institute', 'web', '1733839844.85893', NULL, '1', NULL);
INSERT INTO "content" ("id", "title", "type", "updated_at", "local_storage_location", "ref_counter", "source_url") VALUES ('17B838F0-9EDF-42B1-812D-434F7E1078AB', 'As We May Think - The Atlantic', 'web', '1733839844.86173', NULL, '1', NULL);
"""
	
	let doc_content_sql = """
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', '9D20C4C6-0B65-4D24-BC07-599E3A8BCA70');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', '9FE2BC42-709B-4D01-9385-5B578E3CD0B7');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', '8E242BBE-6636-4CAB-AA8B-3191A8549621');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', 'AC5EF438-4A7E-4AAF-85F4-B1A62B9D3064');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', '0976D8F8-95EC-4196-8C9C-E93459690372');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', '17B838F0-9EDF-42B1-812D-434F7E1078AB');
INSERT INTO "doc_id_content_id" ("document_id", "content_id") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', 'CA26AA21-2A6E-4C5C-90D3-6FA91264A4C3');
"""
	
	let cached_web_sql = """
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('8E242BBE-6636-4CAB-AA8B-3191A8549621', 'https://gloriamark.com/attention-span/', '1733779693.51419', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('AC5EF438-4A7E-4AAF-85F4-B1A62B9D3064', 'https://en.wikipedia.org/wiki/Desktop_metaphor', '1733839814.85791', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('0976D8F8-95EC-4196-8C9C-E93459690372', 'https://www.dougengelbart.org/pubs/augment-3906.html', '1733839844.86', NULL, NULL);
INSERT INTO "cached_Web" ("content_id", "url", "updated_at", "cache", "html_website") VALUES ('17B838F0-9EDF-42B1-812D-434F7E1078AB', 'https://www.theatlantic.com/magazine/archive/1945/07/as-we-may-think/303881/', '1733839844.86322', NULL, NULL);
"""
	
	let notes_sql = """
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('9D20C4C6-0B65-4D24-BC07-599E3A8BCA70', '1733854198.86685', '
Computers are powerful tools for learning, but their impact on our minds isn’t entirely positive.

Attention is our most important personal resource, and we’re losing control over it. The average amount of time people can focus has dropped from 2.5 minutes to 47 seconds in a few years.

The problem is that the Alto-Mac paradigm is aging. And it’s based on assumptions that are no longer true. In particular: isolated devices, a different kind of computer intelligence, and changing ways we use computers. 

Another web browser or knowledge management application can’t address this. We need to think bigger — it’s time for a system-level intervention.

There’s an opportunity now to build a new kind of personal computer. A system to blend websites, documents, and applications in a cohesive environment that’s built to help you focus.

If the last 40 years of personal computing taught us anything, it’s that computers aren’t just the most incredible tool for thought since the alphabet. They also have a profound impact on our emotional lives. That’s why Enai is designed from the ground up to support your intent and care for your attention so that you can focus on what matters to you.

We’re just two people, and we’ve only been building it for a few months. There’s a lot of work to do. If you believe in our mission to build a mindful internet computer, please reach out!
patrick@enai.io (technical co-founder)
curran@enai.io (product co-founder)');
INSERT INTO "user_notes" ("content_id", "updated_at", "raw_text") VALUES ('9FE2BC42-709B-4D01-9385-5B578E3CD0B7', '1733839874.85858', '

Computers can be crowded, overwhelming places. What happened to that file I downloaded? What am I supposed to do with all these tabs I have open? I was learning about why the short Turkish bow is superior to the English longbow a while back - did I ever save it? How do I work on all my projects and stay organized?

We spend too much time manually switching between tasks and let too much knowledge slip through the cracks. The computer’s potential as a thought partner is largely unrealized. Douglas Engelbart, Alan Kay, and Tim Berners-Lee are on record being mortified by the state of things.

The interface paradigm developed at Xerox PARC, the one we’re familiar with, is aging. And it’s based on assumptions that are no longer true. Far less content. Isolated devices. A different kind of computer intelligence.

This is an opportunity to create change. If we can make a better human-computer interface, we end up with people who are calmer, smarter, more focused and effective. So that is what we’re doing.

We can do this because Enai is a whole interface - a container for other software programs. The computer needs to become a place for thought, but another browser, canvas, or pkm tool is unlikely to have the reach to accomplish this. Instead, Enai connects websites, apps, and documents in a holistic context where everything is oriented around your intent. So you can focus, learn, and act more effectively than ever before. You can cultivate a personal knowledge garden in organized spaces with negative effort on your part compared to existing interfaces. And Enai has the semantic knowledge it needs to organize and connect all this knowledge for you.

Your computer should be a partner in connection, a library of memory and knowledge, and a guide to possibilities. Enai will simplify your life, help you think, and make you the most effective version of yourself. We hope you give it a try and become enchanted by the future of computing.

- Curran and Patrick');
"""
	
	let doc_table_sql = """
INSERT INTO "document" ("id", "name", "owner", "shared", "created_at", "updated_at", "updated_by", "document") VALUES ('8B80A304-9ECB-40EB-934E-DABB8D3E82A4', 'Enai Ideas', NULL, '0', '1733856665.32227', '1733856665.32227', NULL, '{
  "type" : "document",
  "data" : {
	"id" : "8B80A304-9ECB-40EB-934E-DABB8D3E82A4",
	"width" : {
	  "px" : 2560
	},
	"height" : {
	  "px" : 2880
	},
	"viewPosition" : {
	  "px" : 0
	},
	"children" : [
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 728
		  },
		  "state" : "sectionTitle",
		  "name" : "Thoughts on why we''re doing this",
		  "position" : {
			"y" : {
			  "px" : 226
			},
			"x" : {
			  "px" : 747
			},
			"posInViewStack" : 1
		  },
		  "id" : "33EE9B46-EC79-4C66-A7B3-6FD544AEB758",
		  "children" : [

		  ],
		  "height" : {
			"px" : 57
		  }
		}
	  },
	  {
		"data" : {
		  "children" : [
			{
			  "id" : "9FE2BC42-709B-4D01-9385-5B578E3CD0B7",
			  "contentType" : "note",
			  "contentState" : "empty",
			  "position" : 0,
			  "active" : true
			}
		  ],
		  "width" : {
			"px" : 710.5
		  },
		  "state" : "frameless",
		  "height" : {
			"px" : 759
		  },
		  "position" : {
			"posInViewStack" : 4,
			"x" : {
			  "px" : 411
			},
			"y" : {
			  "px" : 904.5
			}
		  }
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "height" : {
			"px" : 488
		  },
		  "width" : {
			"px" : 680.5
		  },
		  "position" : {
			"y" : {
			  "px" : 101
			},
			"posInViewStack" : 7,
			"x" : {
			  "px" : 30
			}
		  },
		  "state" : "frameless",
		  "children" : [
			{
			  "contentType" : "img",
			  "id" : "736E9972-42A7-49F8-9141-BE7CA4CA9407",
			  "contentState" : "empty",
			  "active" : true,
			  "position" : 0
			}
		  ]
		}
	  },
	  {
		"data" : {
		  "position" : {
			"y" : {
			  "px" : 827.5
			},
			"posInViewStack" : 2,
			"x" : {
			  "px" : 412
			}
		  },
		  "state" : "sectionTitle",
		  "id" : "4D2349FC-EE64-4459-B077-24489F3FC70E",
		  "width" : {
			"px" : 714
		  },
		  "height" : {
			"px" : 57
		  },
		  "children" : [

		  ],
		  "name" : "Towards a new interface"
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "width" : {
			"px" : 442
		  },
		  "position" : {
			"x" : {
			  "px" : 69
			},
			"y" : {
			  "px" : 1774
			},
			"posInViewStack" : 5
		  },
		  "children" : [
			{
			  "id" : "019A6F08-E125-4268-A23E-06E6274DF4FB",
			  "contentState" : "empty",
			  "contentType" : "img",
			  "active" : true,
			  "position" : 0
			}
		  ],
		  "state" : "frameless",
		  "height" : {
			"px" : 331.5
		  }
		}
	  },
	  {
		"data" : {
		  "state" : "minimised",
		  "height" : {
			"px" : 215
		  },
		  "position" : {
			"posInViewStack" : 3,
			"x" : {
			  "px" : 1172
			},
			"y" : {
			  "px" : 1450
			}
		  },
		  "name" : "References",
		  "width" : {
			"px" : 280
		  },
		  "previousDisplayState" : {
			"state" : "expanded",
			"minimisedOrigin" : {
			  "y" : {
				"px" : 1470.5
			  },
			  "x" : {
				"px" : 1172
			  }
			},
			"defaultWindowOrigin" : {
			  "x" : {
				"px" : 243.5
			  },
			  "y" : {
				"px" : 1315.5
			  }
			},
			"expandCollapseDirection" : "leftToRight"
		  },
		  "children" : [
			{
			  "active" : true,
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "8E242BBE-6636-4CAB-AA8B-3191A8549621",
			  "position" : 0
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "AC5EF438-4A7E-4AAF-85F4-B1A62B9D3064",
			  "position" : 1
			},
			{
			  "contentType" : "web",
			  "contentState" : "loaded",
			  "id" : "0976D8F8-95EC-4196-8C9C-E93459690372",
			  "position" : 2,
			  "active" : false
			},
			{
			  "position" : 3,
			  "contentState" : "loaded",
			  "active" : false,
			  "id" : "17B838F0-9EDF-42B1-812D-434F7E1078AB",
			  "contentType" : "web"
			}
		  ],
		  "id" : "FB2C8C90-6109-458A-875D-321520E3CF8C"
		},
		"type" : "contentFrame"
	  },
	  {
		"type" : "contentFrame",
		"data" : {
		  "state" : "frameless",
		  "children" : [
			{
			  "id" : "9D20C4C6-0B65-4D24-BC07-599E3A8BCA70",
			  "contentType" : "note",
			  "active" : true,
			  "contentState" : "empty",
			  "position" : 0
			}
		  ],
		  "height" : {
			"px" : 385
		  },
		  "position" : {
			"y" : {
			  "px" : 307
			},
			"posInViewStack" : 6,
			"x" : {
			  "px" : 751
			}
		  },
		  "width" : {
			"px" : 718
		  }
		}
	  }
	]
  }
}');

"""
}
