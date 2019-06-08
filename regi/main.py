"""Self-service register demo"""

import cv2, time
import tkinter as tk 
from tkinter.font import Font
from edgetpu.classification.engine import ClassificationEngine
from PIL import Image, ImageTk

# init Tk window
tk_root = tk.Tk()
tk_root.title('Self-service Register with RasPi + Edge TPU')
tk_cam = tk.Canvas(tk_root, width=640, height=480)
tk_cam.grid(row=0, column=0, rowspan=2, padx=10)
tk_font = Font(family='Helvetica', size=18)

# product buttons frame
tk_buttons_frame = tk.Frame(tk_root, width=370, height=300)
tk_buttons_frame.grid(row=0, column=1)

# cart items frame
tk_items_frame = tk.Frame(tk_root, width=370, height=180)
tk_items_frame.grid(row=1, column=1)
tk_items = tk.Listbox(tk_items_frame, height=3, font=tk_font)
tk_items.insert(tk.END, 'test')
tk_items.pack(side=tk.TOP)

# checkout frame
tk_cout_frame = tk.Frame(tk_items_frame, width=370, pady=10) 
tk_cout_frame.pack(side=tk.TOP)
tk_total = tk.Label(tk_cout_frame, font=tk_font,
  text='Total: 1,000')
tk_total.pack(side=tk.LEFT, ipadx=10)
tk_cout_btn = tk.Button(tk_cout_frame, font=tk_font,
  text='Check', height=2)
tk_cout_btn.pack(side=tk.LEFT, ipadx=10)

# init camera
cam = cv2.VideoCapture(0)

# init Edge TPU with TF Lite model
tpu = ClassificationEngine('/home/pi/model.tflite')

# init labels
labels = ['blouse','blouson','cardigan','check shirt','coat','color shirt','down coat','down jacket','down vest','dress','duffle coat','hoodie','jacket','jacket for ladies','knit vest','no sleeve shirt','pants','patterned shirt','polo shirt','school sailor','school suit','shirt','skirt','striped shirt','suit','suit for ladies','sweater','sweater highneck','tie','trench coat','tshirt','vest','wool jacket']

# init label buttons
label_buttons = {} 
for l in labels:
  label_buttons[l] = tk.Button(tk_buttons_frame, font=tk_font, text=l)
label_times = {}

# main
def main():

  # main loop 
  while True:

    # tk update
    tk_root.update_idletasks()
    tk_root.update()

    # capture
    r, img_cam = cam.read()
    img_pil = Image.fromarray(img_cam) 
    img_tk = ImageTk.PhotoImage(img_pil)
    tk_cam.create_image(0, 0, image=img_tk, anchor='nw')

    # classification with tpu
    tpu_results = tpu.ClassifyWithImage(img_pil, top_k=3)

    # update UI 
    print('\n');
    now = time.perf_counter()
    for i, score in tpu_results:

      # print the result
      label = labels[i]
      print(label + ': ' + str(score))
      if score < 0.5:
        break

      # show label button  
      if not label_buttons[label].winfo_ismapped():
        label_buttons[label].pack(side=tk.TOP)
      label_times[label] = now

    # hide older labels
    for l in labels:
      if l in label_times and (now - label_times[l] > 1):
        label_buttons[l].pack_forget()

#    time.sleep(1)

if __name__ == '__main__':
  main()


