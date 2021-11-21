import ueberzug.lib.v0 as ueberzug
import time

with ueberzug.Canvas() as c:
    paths = [""]
    demo = c.create_placement("demo", x=0, y=0, height=50, width=50)
    demo.path = paths[0]
    demo.visibility = ueberzug.Visibility.VISIBLE

    for i in range(2):
        with c.lazy_drawing:
            demo.x = i * 3
            demo.y = i * 3
            demo.path = paths[0]
        time.sleep(1)

    time.sleep(1)
