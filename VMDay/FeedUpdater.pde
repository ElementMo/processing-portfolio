class Profile
{
  Profile(String name, String icon_url)
  {
    name_ = name;
    post_ = 1;
    if (icon_url != null)
    {
      small_ = loadImage(icon_url, "jpg");
      PImage_resize(small_, 0.6);
      String big_url = icon_url.replaceAll("\\/50\\/", "/180/");
      big_ = loadImage(big_url, "jpg");
    }
  }

  color clr_ = color(random(200), random(200), random(200));
  String name_;
  PImage small_, big_;
  int post_;
}
HashMap<String, Profile> g_profiles = new HashMap<String, Profile>();

class FeedUpdater extends Thread
{
  String query_; 
  HashMap<String, Phrase> msgs_ = new HashMap<String, Phrase>();
  float millis = -1000000;//to enable first crawl

  FeedUpdater(String query)
  {
    query_ = query;
  }

  boolean dataChanged = false;

  boolean isDataUpdated()
  {
    return dataChanged;
  }

  Object[] getData()
  {
    //lock msgs_
    dataChanged = false;
    // ArrayList<Phrase> ret = new ArrayList<Phrase>();
    Object[] ret = msgs_.values().toArray();

    //unlock msgs_; 
    return ret;
  }

  void parseXML(String query, ArrayList list)
  {
    doParseXML("http://api.t.sina.com.cn/trends/statuses.xml?source=3709681010&trend_name="+query, list);
  }

  void doParseXML(String input, ArrayList list)
  {  
    list.clear();
    XML xml = loadXML(input);

    int n_xml = xml.getChildCount();
    for (int i = 0; i< n_xml; i++)
    {
      XML phrase = xml.getChild(i);
      XML id = phrase.getChild("id");
      if (id == null)
        continue;
      String mid = id.getContent(); 
      if (debug_feed) 
        println(mid);

      if (!mid.equals("3369607813924731") && !msgs_.containsKey(mid))
      {//check duplicates
        String text = phrase.getChild("text").getContent(); 
        XML user = phrase.getChild("user");
        String screen_name = user.getChild("screen_name").getContent();
        String profile_image_url = user.getChild("profile_image_url").getContent();
        list.add(new Phrase(mid, text, screen_name, profile_image_url));

        dataChanged = true;
      }
    }
    xmlLoading = false;
  }

  void run()
  {
    ArrayList<Phrase> list = new ArrayList<Phrase>();
    while (true)
    {
      if (millis() - millis > 10*1000)
      {
        millis = millis() ;
        println("运行线程:"+query_);
        parseXML(query_, list);
        //lock
        for (Phrase p : list)
        {
          String key = p.id+"";
          if (!msgs_.containsKey(key))
          {
            if (debug_feed)
              println(p.id+":"+p.profile_.name_);
            msgs_.put(key, p);
          }
        }
        //unlock
      }
      else
      {
        try {        
          sleep(1000);
        }
        catch (Exception e) {
        }
      }
    }
  }
}

