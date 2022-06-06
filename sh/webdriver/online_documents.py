import datetime
import json
import os
import re
import time
import argparse

import pandas
from selenium import webdriver
from selenium.webdriver import Keys, ActionChains
from selenium.webdriver.chrome.options import Options
from selenium.webdriver.common.by import By
from selenium.webdriver.support.wait import WebDriverWait

url = "https://docs.qq.com/sheet/DTmV5S3NSZ0lVeWVE?u=7c8a76d46f5e439e839498080d630c35&tab=a1imkx"


def clear_and_backup(driver, name, directory):
    action = action_operate_board(driver)
    action.key_down(Keys.CONTROL).send_keys("a").key_up(Keys.CONTROL).perform()
    action.key_down(Keys.CONTROL).send_keys("c").key_up(Keys.CONTROL).perform()
    write_data = pandas.read_clipboard(sep=",", encoding="UTF-8")
    file_name = str.format("{}\{}.csv", directory, name)
    write_data.to_csv(path_or_buf=file_name, mode="w", encoding="UTF-8")
    action.send_keys(Keys.DELETE).perform()
    return action_move_left_up(driver)


def action_operate_board(driver):
    action = ActionChains(driver)
    operate_board = driver.find_element(By.ID, "canvasContainer").find_element(By.CLASS_NAME, "operate-board")
    time.sleep(2)
    action.click(operate_board).perform()
    return action


def action_move_left_up(driver):
    action = ActionChains(driver)
    input_board = driver.find_element(By.ID, "canvasContainer").find_element(By.CLASS_NAME, "table-input-board")
    time.sleep(2)
    action.click(input_board).perform()
    action_send_keys(action, 100, Keys.ARROW_LEFT)
    action_send_keys(action, 100, Keys.ARROW_UP)
    return action


def action_send_keys(action, count, keys_to_send, doPerform=True):
    for i in range(0, count):
        action.send_keys(keys_to_send)
    if doPerform:
        action.perform()
    return action


def execute_load_data1(config):
    expression = config["expression"]
    file_name = config["filename"]
    title = config["title"]
    pattern = re.compile(expression)
    with open(file_name, encoding="UTF-8") as file:
        read_string = file.read()
    strings = pattern.findall(read_string)
    strings.insert(0, title)
    return strings

def execute_load_data2(config):
    file_name = config["filename"]
    title = config["title"]
    pattern = re.compile(expression)
    with open(file_name, encoding="UTF-8") as file:
        read_string = file.read()
    strings = pattern.findall(read_string)
    strings.insert(0, title)
    return strings


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='information')
    parser.add_argument('--qq', dest="qq", default='771129369', type=str, help='QQ账号')
    parser.add_argument('--config', dest="config", default='online_documents.json', type=str, help='配置文件')
    parser.add_argument('--backup_path', dest="backup_path", default='C:/ProjectG/备份/在线文档', type=str, help='备份文件路径')
    parser.add_argument('--speed', dest="speed", default=2, type=int, help='切换页签的速度(秒)')

    # 路径/c/projectG window会变成 C:/projectG (如果拼接路径会报错)
    args = parser.parse_args()
    with open(args.config, 'r', encoding="UTF-8") as file:
        main_config = json.load(file, strict=False)
    options = Options()
    driver = webdriver.Chrome(options=options)
    action = ActionChains(driver)
    try:
        driver.get(url)
        wait = WebDriverWait(driver, 5)
        driver.maximize_window()
        driver.find_element(By.ID, "blankpage-button-pc").click()
        driver.implicitly_wait(2000)
        login_tabs = driver.find_element(By.ID, "id-login-tabs")
        login_tabs.find_element(By.ID, "qq-tabs-title").click()
        driver.implicitly_wait(2000)
        login_frame = driver.find_element(By.ID, "login_frame")
        driver.switch_to.frame(login_frame)

        driver.find_element(By.ID, "img_" + args.qq).find_element(By.XPATH, "..").click()
        time.sleep(2)
        sheet_tabs = driver.find_element(By.ID, "sheetbarContainer").find_elements(By.CLASS_NAME, "sheet-box.sheet.sheet-tab-blur")
        directory = args.backup_path + "/" + datetime.datetime.strftime(datetime.datetime.now(), '%Y%m%d%H%M')
        if not os.path.exists(directory):
            os.makedirs(directory)
        for sheet_tab in sheet_tabs:
            text = sheet_tab.get_attribute("innerText")
            match_strings = []
            sheet_tab.click()
            time.sleep(args.speed)  # 简单处理,每个页签都切换就可以
            if text in main_config:
                config = main_config[text]
                action = clear_and_backup(driver, text, directory)
                typeId = config["typeId"]
                if typeId == 1:
                    match_strings = execute_load_data1(config)
                elif typeId == 2:
                    match_strings = execute_load_data1(config)
            for match_string in match_strings:
                length = len(match_string)
                for index in range(0, length):
                    action_send_keys(action, 1, match_string[index], False)
                    action_send_keys(action, 1, Keys.ARROW_RIGHT, False)
                action_send_keys(action, 1, Keys.ARROW_DOWN, False)
                action_send_keys(action, length, Keys.ARROW_LEFT, True)
    finally:
        driver.quit()
