#!/usr/bin/python
# coding=utf8
import argparse
import datetime
import difflib
import filecmp
import os

def splitlines(filename):
    text_lines = []
    if os.path.exists(filename):
        file = open(filename, "r", encoding="utf-8")
        text = file.read()
        text_lines = text.splitlines()
    return text_lines


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='information')
    parser.add_argument('--commit-id', dest='commit_id', type=str, help='显示提交commit的版本号', default="NONE")
    parser.add_argument('--filename', dest='filename', type=str, help='需要比較的文件名稱')
    parser.add_argument('--version-path', dest='version_path', type=str, help='比较版本的文件路径')
    parser.add_argument('--current-path', dest='current_path', type=str, help='最新版本的文件路径')
    parser.add_argument('--html-path', dest='html_path', type=str, help='生成的文件路径', default="./")

    args = parser.parse_args()
    version_path = os.path.join(args.version_path, args.filename)
    current_path = os.path.join(args.current_path, args.filename)
    version_lines = splitlines(version_path)
    current_lines = splitlines(current_path)
    d = difflib.HtmlDiff()
    date_string = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
    html_message = d.make_file(version_lines, current_lines, args.commit_id, date_string, context=True, numlines=5)
    html_message = html_message.encode()
    html_name = "{}/{}.html".format(args.html_path, args.filename).replace("\\", "/")
    dirname = os.path.dirname(html_name)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    fp = open(html_name, "w+b")
    fp.write(html_message)
    fp.close()
