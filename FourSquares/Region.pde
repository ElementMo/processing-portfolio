// Region has several Buttons
static int sPinCounter = kPinBase;

class Region
{
    class VertexData
    {
        VertexData(String filename)
        {
            for (String line : loadStrings(filename))
            {
                int commaIndex = line.indexOf(",");
                if (commaIndex != -1)
                {
                    int assignIndex = line.indexOf("=");
                    String key = line.substring(0, assignIndex);
                    int x = int(line.substring(assignIndex + 2, commaIndex));
                    int y = int(line.substring(commaIndex + 1, line.length() - 1));
                    //                    println(key + ":" + x + ", " + y);
                    mVertices.put(key, new PVector(x, y));
                }
            }
        }
        Map<String, PVector> mVertices = new HashMap<String, PVector>();
    }

    VertexData mVertexData;

    void update(Movie movie)
    {
        for (Button button: mButtons)
        {
            button.update(movie);
        }
    }

    void draw2D(int x, int y)
    {
        for (Button button: mButtons)
        {
            button.draw2D(x, y);
        }
    }

    void draw1D(int x, int y)
    {
        for (Button button: mButtons)
        {
            x = button.draw1D(x, y);
        }
    }

    Region(String regionName)
    {
        println(regionName+":");
        mVertexData = new VertexData(regionName);

        Button aButton = null;
        for (String line : loadStrings(regionName+".order"))
        {
            if (line.length() == 0) continue;

            if (line.charAt(0 ) == ':')
            {
                if (aButton != null)
                {
                    aButton.markEnd();
                }
                aButton = new Button(line.substring(1, 3), sPinCounter++);
                //                println(aButton);
                mButtons.add(aButton);
            }
            else
            {
                String vertexId = line;
                PVector vertex = mVertexData.mVertices.get(vertexId);
                aButton.addVertex(vertex);
            }
        }
        aButton.markEnd();

        printArray(mButtons);
        print("\n");
    }
    ArrayList<Button> mButtons = new ArrayList<Button>();
}

