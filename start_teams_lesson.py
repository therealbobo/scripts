#! /usr/bin/env python

import pyautogui
import time


pyautogui.moveTo(100, 100, duration=0.25)
time.sleep(0.2)
pyautogui.press('esc',interval=0.1)
time.sleep(0.2)
pyautogui.press('tab',interval=0.1)
time.sleep(1)
pyautogui.press('enter',interval=0.1)
time.sleep(5)

pyautogui.click(960, 600, duration=0.25)
time.sleep(5)
pyautogui.click(1110, 900, duration=0.25)
time.sleep(5)
pyautogui.click(1180, 750, duration=0.25)

