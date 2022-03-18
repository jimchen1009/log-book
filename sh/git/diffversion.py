#!/usr/bin/python
# coding=utf8
import argparse
import os
import datetime
from jinja2 import Template, escape


# 暂时写死模板
temple_string = '''
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html class="eye-protector-processed" style="background-color: rgb(193, 230, 198);"><head><meta http-equiv="Content-Type" content="text/html; charset=UTF-8">

<p><b>比较日期：</b>{{ current_date }}</p>
<table align="left" cellpadding="5" frame="void">
{% if author_datalist %}
    {% for author_data in author_datalist %}
    <tr><td><table align="left" cellpadding="3" frame="box">
        <tr><th>
        {{ author_data.author }}
        </th></tr>
        {% for file in author_data.files %}
        <tr><td><li><a href="{{ file.url }}">{{ file.name }}</a></li></td></tr>
        {% endfor %}
    </table></td></tr>
    {% endfor %}
{% endif %}
</table>
'''


def gen_author_data(filename):
    author = os.path.basename(filename)
    author = os.path.splitext(author)[0]
    files = []
    if os.path.exists(filename):
        file = open(filename, "r", encoding="utf-8")
        text = file.read()
        text_lines = text.splitlines()
        for text_line in text_lines:
            files.append({"name": text_line, "url": "{}.html".format(text_line)})
        author = "{}  ({})".format(author, len(text_lines))

    directory = {"author": author, "files": files}
    return directory


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description='information')
    parser.add_argument('--author_names', dest='author_names', type=str, help='文件名')
    parser.add_argument('--author_path', dest='author_path', type=str, help='文件列表:,号分割')
    parser.add_argument('--html_pathname', dest='html_pathname', type=str, help='生成的文件路径', default="C:/ProjectG-v0/author_commit/a.html")

    # 路径/c/projectG window会变成 C:/projectG (如果拼接路径会报错)
    args = parser.parse_args()
    print(args.author_path, end="\n")
    author_names = str.split(args.author_names, ",")
    author_datalist = []
    for author_name in author_names:
        filename = "{}/{}.txt".format(args.author_path, author_name).replace("\\", "/")
        print(filename, end="\n")
        author_data = gen_author_data(filename)
        author_datalist.append(author_data)

    date_string = datetime.datetime.strftime(datetime.datetime.now(), '%Y-%m-%d %H:%M:%S')
    template = Template(temple_string)
    html_message = template.render(current_date=date_string, author_datalist=author_datalist)
    html_name = args.html_pathname.replace("\\", "/")
    dirname = os.path.dirname(html_name)
    if not os.path.exists(dirname):
        os.makedirs(dirname)
    fp = open(html_name, "w+", encoding="utf-8")
    fp.write(html_message)
    fp.close()
