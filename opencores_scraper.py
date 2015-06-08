#!/usr/bin/env python
#-*- coding:utf-8 -*-
#
'''
This is a one-file python script that download locally the content of the WHOLE
project section of the website opencores.org.
The downloaded content is then stored in a local folder.
To use this script, an opencores.org account is needed. Also note that the whole
opencores.org database is around 3GB of data.

The Python libraries needed for this script can be installed with the command:

    sudo pip install beautifulsoup mechanize cssselect
'''
#
# HOW TO USE THIS SCRIPT
#
# 0) install python and its dependencies: easy_install beautifulsoup meachanize
# 1) make an account in opencores.org
# 2) complete the "basic setup" section below with the login data
# 3) run this script with the command:  ./opencores_scraper.py >> oc.log
#
#
#_______________________________ basic setup ___________________________________
#
prj_to_download = 1E99        # set to 1E99 to get all projects
download_prj_svn = True       # set to True to get opencores project svn acchives (.zip)
github_upload = True          # set to True to upload all local folder to
                              # your github repository
oc_user='xxxxxxxx'            # opencores.org login
oc_pwd='xxxxxxxxxxxx'         # opencores.org password

#_______________________________ github upload _________________________________
#
_github_addr = 'https://github.com/fabriziotappero/ip-cores.git'
_github_login = 'xxxx'
_github_pw = 'xxxx'
#_______________________________________________________________________________


# import web scrape tools and other libs
import re, sys, os, time
import lxml.html, pickle, tarfile
#import ftputil
from BeautifulSoup import BeautifulSoup, Comment
import mechanize, cookielib

# function to get all opencores projects from a specific opencores URL
def get_projects(_url):
    r = br.open(_url)
    _html_content = r.read()
    # convert the HTML into lxml object
    _lxml_content = lxml.html.fromstring(_html_content)

    # Extract all projects
    projects_name = []
    projects_url = []

    # Find all 'a' elements inside 'tbody tr.row1 td.project'
    for a in _lxml_content.cssselect('tbody tr td.project a'):
        projects_name.append(a.text)

    # Find all 'a' elements inside 'tbody tr.row1 td.project' and
    # get the 'href' link
    links = _lxml_content.cssselect('tbody tr td.project a')
    for a in links:
        projects_url.append(a.get('href'))

    # make sure that number of projects is equal to the number of prj links
    if len(projects_name) != len(projects_url):
        print 'ERROR. some projects do not have a URL.'
        sys.exit(1)

    # clean up text with regular expressions because
    # project names contains unwanted spaces and carriage returns
    # replace/delete unwanted text
    for i,x in enumerate(projects_name):
        x = x.encode('utf-8')
        x = x.lower()
        x = re.sub('(\\n *)','',x)
        x = re.sub(' +',' ',x)
        x = re.sub(' - ','-',x)
        x = re.sub(' / ','/',x)
        x = x.lstrip().rstrip()
        if x.startswith('a '): x = x[2:]
        if len(x)>50: x=x[:50]
        projects_name[i] = x

    for i,x in enumerate(projects_url):
        x = x.encode('utf-8')
        x = re.sub('(\\n *)','',x)
        x = re.sub(' +',' ',x)
        x = x.lstrip().rstrip()
        projects_url[i]= "http://www.opencores.org/" + x

    return projects_name, projects_url

# structure to store everything
class opencores():
    def __init__(self,):
        self.categories=[]
        self.categories_num=0
        self.categories_url=[]
        self.projects_url=[]
        self.projects_name=[]
        self.projects_num=[]
        self.projects_html_info=[]
        self.projects_download_url=[]
        self.projects_to_be_downloaded_flag=[]
        self.projects_created = []
        self.projects_last_update = []
        self.projects_archive_last_update = []
        self.projects_lang = []
        self.projects_license = []
        self.projects_dev_status = []

# function to rename any multiple element of the list 'ar'
# 'ar' must be a list of strings

def rename_multiple(ar):
    #ar = ['a','er1','a4','erta','a','er']
    for x in ar:
        i=[n for (n, e) in enumerate(ar) if e.lower() == x.lower()]
        #print i
        if len(i)>1:
            _ind=1
            for y in i:
                ar[y]=ar[y]+' '+str(_ind)
                _ind = _ind + 1
                print 'WARNING. '+\
                      'Found two projects with same name. Will rename:', ar[y]
    return ar

# clean up html code from unwanted portions of the page
def filter_html(in_html):
    doc = BeautifulSoup(in_html)

#recs = doc.findAll("div", { "class": "class_name"})

    # remove unwanted tags
    for div in doc.findAll('head'):
        div.extract()
    for div in doc.findAll(['i', 'h1', 'script']):
        div.extract()
    for div in doc.findAll('div','top'):
        div.extract()
    for div in doc.findAll('div','bot'):
        div.extract()
    for div in doc.findAll('div','line'):
        div.extract()
    for div in doc.findAll('div','mainmenu'):
        div.extract()
    for div in doc.findAll('div','banner'):
        div.extract()
    for div in doc.findAll('div','maintainers'):
        div.extract()

    #for div in doc.findAll('div', {'style':'clear:both;margin-left:200px;'}):
    #    div.extract()

    # remove html comments
    comments = doc.findAll(text=lambda text:isinstance(text, Comment))
    [comment.extract() for comment in comments]

    out_html = doc.body.prettify()

    # a little more cleaning up
    out_html = re.sub('(<dd>)\\n','',out_html)
    out_html = re.sub('(</dd>)\\n','',out_html)
    out_html = re.sub('<br />','<br/>',out_html)
    out_html = re.sub('<br/>\\n *<br/>','<br/>',out_html)
    out_html = re.sub('\\n *\\n','\\n',out_html)
    return out_html

# get folder size
def getFolderSize(folder='.'):
    total_size = os.path.getsize(folder)
    for item in os.listdir(folder):
        itempath = os.path.join(folder, item)
        if os.path.isfile(itempath):
            total_size += os.path.getsize(itempath)
        elif os.path.isdir(itempath):
            total_size += getFolderSize(itempath)
    return total_size

def get_size(_path = '.'):
    total_size = getFolderSize(_path)
    if total_size >= 1.0E9:
        _out = str(round(total_size/1.0E9,2))+' GB' # return size in GB
    else:
        _out = str(round(total_size/1.0E6,2))+' MB' # return size in MB
    return _out

################################ MAIN ##########################################

# create a structure to save all information from opencores.org
opencores_mem = opencores()

# Browser
br = mechanize.Browser()

# Cookie Jar
cj = cookielib.LWPCookieJar()
br.set_cookiejar(cj)

# Browser options
br.set_handle_equiv(True)
#br.set_handle_gzip(True)
br.set_handle_redirect(True)
br.set_handle_referer(True)
br.set_handle_robots(False)

# Follows refresh 0 but not hangs on refresh > 0
br.set_handle_refresh(mechanize._http.HTTPRefreshProcessor(), max_time=1)

# Want debugging messages?
#br.set_debug_http(True)
#br.set_debug_redirects(True)
#br.set_debug_responses(True)

# User-Agent (this is cheating, ok?)
br.addheaders = [('User-agent', 'Mozilla/5.0 (X11; U; Linux i686; en-US; '+\
               'rv:1.9.0.1) Gecko/2008071615 Fedora/3.0.1-1.fc9 Firefox/3.0.1')]

# Open opencores.org login page and select the first form in the page
# maybe a better method to search for the form would be better
r = br.open("http://www.opencores.org/login")
br.select_form(nr=0)

#Aauthenticate and submit
br['user'] = oc_user
br['pass'] = oc_pwd

# TODO check that you have successfully authenticated
res = br.submit()
#print res.get_data()

# Access a password protected site
print 'Time:', time.asctime()
r = br.open("http://www.opencores.org/projects")
print 'Opening website: http://www.opencores.org/projects\n'

# Open page
_html_content = r.read()
_lxml_content = lxml.html.fromstring(_html_content) # turn HTML into lxml object

# Extract all project categories with some cleaning
for el in _lxml_content.cssselect("span.title"):
    x = el.text
    x = x.encode('utf-8')
    x = x.lower()
    x = re.sub(' +',' ',x)
    x = re.sub(' - ','-',x)
    x = re.sub(' / ','/',x)
    x = x.lstrip().rstrip()
    if x.startswith('a '): x = x[2:]
    if len(x)>50: x=x[:50]
    opencores_mem.categories.append(x)

# Extract all url for each project category
# with: "GET http://opencores.org/projects,category,0"
for x in range(len(opencores_mem.categories)):
    opencores_mem.categories_url.append('http://www.opencores.org/projects,category,'+str(x))

# Extract all project names for each url that defines a category
for i,x in enumerate(opencores_mem.categories_url):
    prjs_name, prjs_url  = get_projects(x)
    opencores_mem.projects_url.append(prjs_url)
    opencores_mem.projects_name.append(prjs_name)
    opencores_mem.projects_num.append(len(prjs_url))

    # count how many projects there are in this specific category
    print 'Grand total of',len(prjs_url),\
          'projects in the category:',\
          opencores_mem.categories[i]

# count how many projects and categories there are
opencores_mem.categories_num = len(opencores_mem.categories)
print '\n',\
      'Total number of available projects:', sum(opencores_mem.projects_num)
print 'Total number of available categories:', opencores_mem.categories_num,'\n'
print 'Time:', time.asctime()


# create a structure used to store everything from opencores.org
print 'Allocating memory to store opencores.org content.'
for x in opencores_mem.projects_name:
    opencores_mem.projects_html_info.append(['None']*len(x))
    opencores_mem.projects_download_url.append(['Unknown']*len(x))
    opencores_mem.projects_to_be_downloaded_flag.append([True]*len(x))
    opencores_mem.projects_created.append(['Unknown']*len(x))
    opencores_mem.projects_last_update.append(['Unknown']*len(x))
    opencores_mem.projects_archive_last_update.append(['Unknown']*len(x))
    opencores_mem.projects_lang.append(['Unknown']*len(x))
    opencores_mem.projects_license.append(['Unknown']*len(x))
    opencores_mem.projects_dev_status.append(['Unknown']*len(x))

# Extract html info page and its latest SVN downland link. Do this for each project
# since there is an html page for each projct, this routine will need some time
prj_without_svn_count = 0
for i,x in enumerate(opencores_mem.projects_name):

    print 'Project category:',opencores_mem.categories[i].upper()
    # go throuh all the projects in each category
    for ii,y in enumerate(x):
        _url=opencores_mem.projects_url[i][ii]
        print '[' + time.asctime() + ']','\nDownloading HTML information from:\n', _url
        whole_html = br.open(_url).read()
        _html = filter_html(whole_html)
        opencores_mem.projects_html_info[i][ii] = _html

        #extract project download link for each project
        _lxml_content = lxml.html.fromstring(whole_html) #turn the HTML into lxml object
        links = _lxml_content.cssselect('body a') #TODO this is maybe not so unique...
        # TODO find a better way to create the array: opencores_mem.projects_download_url
        found_flag = False
        for x in links:
            if x.text == 'download':
                if  x.get('href').replace('download,','') != '': # if it's not an empty link
                    opencores_mem.projects_download_url[i][ii] = 'http://www.opencores.org' + x.get('href')
                    print 'Latest download link found at:\nhttp://www.opencores.org' + x.get('href')+'\n'
                    found_flag = True
                    break
        if not found_flag:
            opencores_mem.projects_download_url[i][ii] = 'No_svn_archive_link_available'
            print 'WARNING. LATEST SVN DOWNLOAD LINK NOT FOUND\n'
            prj_without_svn_count += 1


        # extract some info from the page. Because of the complicated structure
        # of these html pages, this info extraction is not so easy.
        #
        # created data
        try:
            _txt = _lxml_content.xpath("//*[contains(text(),'Details')]/following-sibling::*")[0].cssselect('br')[0].tail
            _txt = _txt.split(':')[-1]
            if _txt == None: _txt = 'Unknow'
            opencores_mem.projects_created[i][ii] = _txt
        except:
            pass
        #
        # last update date
        try:
            _txt = _lxml_content.xpath("//*[contains(text(),'Details')]/following-sibling::*")[0].cssselect('br')[1].tail
            if _txt == None or _txt == '': _txt = 'Unknow'
            _txt = _txt.split(':')[-1]
            _txt = re.sub(' +',' ',_txt)
            _txt = _txt.lstrip().rstrip()
            opencores_mem.projects_last_update[i][ii] = _txt
        except:
            pass
        #
        # archive last update date
        try:
            _txt = _lxml_content.xpath("//*[contains(text(),'Details')]/following-sibling::*")[0].cssselect('br')[2].tail
            if not 'SVN Updated:' in _txt: _txt = 'Unknow'
            if _txt == None or _txt == '': _txt = 'Unknow'
            _txt = _txt.split(':')[-1]
            _txt = re.sub(' +',' ',_txt)
            _txt = _txt.lstrip().rstrip()
            opencores_mem.projects_archive_last_update[i][ii] = _txt
        except:
            pass
        #
        # language
        try:
            #if _lxml_content.xpath("//h2[contains(text(),'Other project properties')]/following-sibling::*")[0].cssselect('a'):
            _txt = _lxml_content.xpath("//*[contains(text(),'Other project properties')]/following-sibling::*")[0].cssselect('a')[1].text
            if _txt == None: _txt = 'Unknow'
            opencores_mem.projects_lang[i][ii] = _txt
        except:
            pass
        #
        # development status
        try:
            _txt = _lxml_content.xpath("//*[contains(text(),'Other project properties')]/following-sibling::*")[0].cssselect('a')[2].text
            if _txt == None: _txt = 'Unknow'
            opencores_mem.projects_dev_status[i][ii] = _txt
        except:
            pass
        #
        # License
        try:
            _txt = _lxml_content.xpath("//*[contains(text(),'Other project properties')]/following-sibling::*")[0].cssselect('br')[4].tail
            _txt = _txt.replace('\n','')
            _txt = _txt.replace(' ','')
            if _txt == None or len(_txt)<=8: _txt = ':Unknown'
            _txt = _txt.split(':')[-1]
            opencores_mem.projects_license[i][ii] = _txt
        except:
            pass

        # REFERENCE. this is an other method to select elements inside an xml document
        #
        # created_date = _lxml_content.cssselect('div.content p')[0].cssselect('br')[0].tail
        # svn_link =     _lxml_content.cssselect('div.content p')[0].cssselect('a')[2].get('href')
        # category   = _lxml_content.cssselect('div.content p')[1].cssselect('a')[0].text

        ###################### this will download only some info files per category
        if ii >= prj_to_download:
            break

# rename any project name that appears double
for i,x in enumerate(opencores_mem.projects_name):
    opencores_mem.projects_name[i] = rename_multiple(opencores_mem.projects_name[i])

# store locally all info about the latest content of opencores website
# this file is not really used. pickle is a good way to store python stuff
if os.path.isdir('./cores'):
    fl=open('cores/opencores_web_latest.pkl','w')
    pickle.dump(opencores_mem, fl)
    fl.close()

# create local folder structure
if not os.path.exists('./cores'):
    os.makedirs('./cores')
    print 'Creating folder structure.'
else:
    print 'WARNING. Local directory "./cores" already exists. Its content will be updated'

for i,x in enumerate(opencores_mem.categories):
    x = re.sub(' ','_',x)
    x = re.sub('/','-',x)
    try:
        os.makedirs('./cores/'+x)
        print 'Creating folder:','./cores/'+x
    except:
        pass
    for y in opencores_mem.projects_name[i]:
        y = re.sub(' ','_',y)
        y = re.sub('/','-',y)
        try:
            os.makedirs('./cores/'+x+'/'+y)
            print 'Creating folder:','./cores/'+x+'/'+y
        except:
            pass

# copying project html information in each project folder EVEN IF ALREADY EXISTS
for i,x in enumerate(opencores_mem.categories):
    x = re.sub(' ','_',x)
    x = re.sub('/','-',x)
    for ii,y in enumerate(opencores_mem.projects_name[i]):
        y = re.sub(' ','_',y)
        y = re.sub('/','-',y)
        try:
            fl_nm = './cores/'+x+'/'+y+'/index.html'
            print 'Writing file:', fl_nm
            fl=open(fl_nm,'w')

            # add style.css link
            _header = '<head>\n'+'<link rel="stylesheet" href="../../style.css" type="text/css">\n'+'</head>\n'
            fl.write(_header)

            # clean up all links TODO this will actually delete all links... a more selective method could be better
            from lxml import etree
            tree = etree.fromstring(opencores_mem.projects_html_info[i][ii])
            etree.strip_tags(tree,'a')
            _out = etree.tostring(tree,pretty_print=True)

            # delete the three links
            _out = re.sub('<br/>\n *SVN:\n *\n *Browse','',_out)
            _out = re.sub('<br/>\n *Latest version:\n *\n *download','',_out)
            _out = re.sub('<br/>\n *Statistics:\n *\n *View','',_out)

            # add source code link at the top
            _link = opencores_mem.projects_download_url[i][ii].encode('utf-8')
            source_ln = re.sub('http://www.opencores.org/download,', '', _link)
            source_ln = source_ln +'.tar.gz'
            fl.write('<a href="javascript:history.go(-1)" onMouseOver="self.status=document.referrer;return true">Go Back</a>\n')
            fl.write("<p align='right'><a href='" + source_ln + "'>Source code</a></p>\n")

            fl.write(_out)
            fl.write("<p id='foot'>"+time.strftime('Database updated on %d %B %Y')+"</p>\n")
            fl.close()
        except:
            pass

# count how many downloadable .zip projects are available for download
av_size = 0
for x in opencores_mem.projects_download_url:
    for y in x:
        if 'http://www.opencores.org/download,' in y:
            av_size =av_size +1
print '\n','Total number of downloadable SVN project archives:', av_size
print 'NOTE. Of the', sum(opencores_mem.projects_num), \
      'project folders available on opencores.com only\n', \
      av_size,'SVN project archives are available for download.'

print 'Time:', time.asctime()

# load info about what was downloaded last time from local file and flag
# what needs to be update/downloaded

# let's begin from a download all configuration. Remember that
# all flags are in fact set to "True" during the creation
# of the list "opencores_mem.projects_to_be_downloaded_flag"
#DOWNLOAD_TYPE = 'total'

# let's see now if we can avoid some downloads
if os.path.isfile('./cores/opencores_local.pkl'):
    fl=open('./cores/opencores_local.pkl','r')
    opencores_mem_local = pickle.load(fl)
    fl.close()
    for i,x in enumerate(opencores_mem.projects_name):
        for ii,y in enumerate(x):
            # search for y project name in local project list of same category
            if y in opencores_mem_local.projects_name[i]:
                ind = opencores_mem_local.projects_name[i].index(y) # position of the project that might not need to be upgraded
                # compare the last update date and the last archive update date
                if opencores_mem.projects_last_update[i][ii] == opencores_mem_local.projects_last_update[i][ind]:
                    if opencores_mem.projects_archive_last_update[i][ind] == opencores_mem_local.projects_archive_last_update[i][ind]:
                        # bingo ! this project y does not need to be upgraded
                        #DOWNLOAD_TYPE = 'partial'
                        print "WARNING. the project", y, "doesn't need to be downloaded."
                        opencores_mem.projects_to_be_downloaded_flag[i][ii]=False
    del opencores_mem_local

# let's download all project archives flagged as "True" in "opencores_mem.projects_to_be_downloaded_flag"
if download_prj_svn:
    print 'Ready to download', av_size,'.zip project archives.'
    dw_cnt = 0
    for i,x in enumerate(opencores_mem.projects_download_url):
        for ii,y in enumerate(x):
            y = y.encode('utf-8')
            if ('http://www.opencores.org/download,' in y) and opencores_mem.projects_to_be_downloaded_flag[i][ii]==True:
                r = br.open(y)
                tar_gz_content = r.read()
                fl_nm = re.sub('http://www.opencores.org/download,', '', y)
                a = re.sub(' ','_',opencores_mem.categories[i])
                b = re.sub(' ','_',opencores_mem.projects_name[i][ii])
                a = re.sub('/','-',a)
                b = re.sub('/','-',b)
                fl_nm = './cores/'+a+'/'+b+'/'+fl_nm+'.tar.gz'
                print 'Saving file:', fl_nm
                fl=open(fl_nm, 'wb')
                fl.write(tar_gz_content)
                fl.close()
                dw_cnt = dw_cnt + 1
                print dw_cnt, 'of',av_size,'.zip files downloaded.'
    print 'Total number of opencores.org projects:', sum(opencores_mem.projects_num)
    print 'Total number of downloaded .zip projects:', dw_cnt
    print 'Total number of project without .zip archive:', prj_without_svn_count

    # now all projects must have been downloaded. We can now update the local
    # log file
    print 'Saving local log file: "./cores/opencores_local.pkl".'
    fl=open('./cores/opencores_local.pkl','w')
    pickle.dump(opencores_mem, fl)
    fl.close()

# create a global index.html with a list of all projects in a table format
if not os.path.exists('./cores'):
    os.makedirs('./cores')
fl=open('./cores/index.html','w')
fl.writelines('''
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Open-Source IP Core Server</title>
<link rel="stylesheet" href="style.css" type="text/css">

<script type="text/javascript" src="http://ajax.googleapis.com/ajax/libs/jquery/1.4/jquery.min.js"></script>
		<script type="text/javascript" src="jquery.quicksearch.js"></script>
		<script type="text/javascript">
			$(function () {
				/*
				Example 1 (the one in use)
				*/
				$('input#id_search').quicksearch('table tbody tr',{'delay': 300,
					'stripeRows': ['odd', 'even']});
			});
		</script>
</head>
<body>
''')
fl.write('<p align="right"><a href="license.html">About this Page</a> &bull; <a href="license.html">License and disclaimer</a></p>')
fl.write('<p>Database size: '+get_size('./cores')+'</p>\n')
fl.write('<p>Available projects: '+str(sum(opencores_mem.projects_num))+'</p>\n')
fl.write('<p>Project categories: '+str(len(opencores_mem.categories))+'</p>\n')
fl.write('''
<form action="#">
<fieldset>Search:
<input type="text" name="search" value="" id="id_search" placeholder=" ex. ddr memory controller" autofocus />
</fieldset>
</form>
''')

fl.write('''
<table id="table_example">
<thead>
    <tr>
        <th width="30%">Project Name</th>
        <th width="5%">.zip Archive</th>
        <th width="8%">Last Update</th>
        <th width="8%">Language</th>
        <th width="5%">Dev. status</th>
        <th width="5%">License</th>
    </tr>
</thead>
    <tbody>
''')


for i,x in enumerate(opencores_mem.projects_download_url):
    _c = opencores_mem.categories[i].encode('utf-8')
    fl.write("<tr><td>")
    fl.write('  <b> Category: '+_c.upper()+'</b>'+'\n')
    fl.write("</td></tr>\n")
    for ii,y in enumerate(opencores_mem.projects_download_url[i]):
        y = y.encode('utf-8')
        _n = opencores_mem.projects_name[i][ii]
        a = re.sub(' ','_',_c)
        b = re.sub(' ','_',_n)
        a = re.sub('/','-',a)
        b = re.sub('/','-',b)
        link = a+'/'+b+'/'+'index.html'
        source_ln = re.sub('http://www.opencores.org/download,', '', y)
        source_ln = a+'/'+b+'/'+ source_ln +'.tar.gz'
        # shorten the language label if too long
        if len(opencores_mem.projects_lang[i][ii])>7:
            opencores_mem.projects_lang[i][ii]=opencores_mem.projects_lang[i][ii][:7]

        # lets put in the table a hidden field for each project with the info
        # from the project html page
        soup = BeautifulSoup(opencores_mem.projects_html_info[i][ii])
        html_info = soup.text.encode('ascii','ignore') # you need to convert from unicode to text
        html_info = html_info[250:850] # trip it and just get the last 600 characters

        fl.write("<tr><th>")
        # here the use of a hidden field allows tho bind this project with its
        # group. Very good for the search function.
        fl.write("<div hidden>"+_c+' '+html_info+"</div><a href='"+link+"'>"+_n+"</a>") # project name
        fl.write("</th><td>")
        fl.write("<a href='" + source_ln + "'>code</a>")              # source code link
        fl.write("</td><td>")
        fl.write(opencores_mem.projects_last_update[i][ii])           # last update
        fl.write("</td><td>")
        fl.write(opencores_mem.projects_lang[i][ii])                  # language
        fl.write("</td><td>")
        fl.write(opencores_mem.projects_dev_status[i][ii])            # dev. status
        fl.write("</td><td>")
        fl.write(opencores_mem.projects_license[i][ii])               # license type
        fl.write("</td></tr>\n")
fl.write("</tbody></table>\n")
fl.write("<p id='foot'>"+time.strftime('Updated on %d %B %Y')+"</p>\n")
fl.write(' </body>\n</html>\n')
fl.close()

# created css file
fl=open('./cores/style.css','w')
fl.write('''

p { line-height: 1.2em;
    margin-bottom: 2px;
    margin-top: 2px;}


body {min-width:820px;
      color: #333333;
      font-family: Arial,Helvetica,sans-serif;
	  font-size : 11pt;
      margin-left: 10px;
      margin-right: 10px;
      margin-bottom: 10px;
      margin-top: 10px;}

a {text-decoration: none; color: #1F7171;}
a:hover {text-decoration: underline;}

#h1,h2,h3 {margin:10px 0px 5px 0px;}

form { margin: 50px 10px;}
table { width: 100%; border-collapse: collapse; margin: 1em 0; }

#id_search {
  -webkit-box-sizing: border-box;
  -moz-box-sizing: border-box;
  box-sizing: border-box;
  display: block;
  padding: 11px 7px;
  padding-right: 43px;
  background-color: #fff;
  font-size: 1.6em;
  color: #ccc;
  border: 1px solid #c8c8c8;
  border-bottom-color: #d2e2e7;
  -webkit-border-radius: 1px;
  -moz-border-radius: 1px;
  border-radius: 1px;
  -webkit-box-shadow: inset 0 1px 2px rgba(0,0,0,0.1), 0 0 0 6px #f0f0f0;
  -moz-box-shadow: inset 0 1px 2px rgba(0,0,0,0.1), 0 0 0 6px #f0f0f0;
  box-shadow: inset 0 1px 2px rgba(0,0,0,0.1), 0 0 0 6px #f0f0f0;
  -webkit-transition: all 0.4s linear;
  -moz-transition: all 0.4s linear;
  transition: all 0.4s linear;
  width: 100%; }

.odd, .r1 { background: #fff; }
.even, .r2 { background: #eee; }
.r3 { background: #ebebeb; }
.search { font-weight:  bold; }
.new { color: #f34105; text-transform: uppercase; font-size: 85%; margin-left: 3px; }


thead th { background: #077474; color: #fff; }

tbody th { text-align: left; }
table th, table td { border: 1px solid #ddd; padding: 2px 5px; font-size: 95%; font-weight: normal; }
pre { font-size: 130%; background: #f7f7f7; padding: 10px 10px; font-weight: bold; }


fieldset { border: 0px solid #ccc; padding: 5px;}
#form input { font-size: 16px; border: 1px solid #ccc;}

#foot{margin-top: 10px;
      text-align: center;
      color:#A8A8A8;
      font-size : 90%;}
''')
fl.close()
print 'Local style.css file created.'


# created license.html file
fl=open('./cores/license.html','w')
fl.write('''
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>IP Cores - license</title>
</head>
<body>
<h2>Disclaimer</h2>
<p>We make no warranties regarding the correctness of the data and disclaim
liability for damages resulting from its use.</p>
<p>This database is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.</p>
<p>We cannot provide unrestricted permission regarding the use of the data,
as some data may be covered by a specific license or other rights. Please
refer to the license notice that comes with each core project description.</p>
</body>
</html>

''')
fl.close()
print 'Local license.html file created.'

# created example.json file
fl=open('./cores/example.json','w')
fl.write('''
{
	"list_items": ["Loaded with Ajax", "Loaded with Ajax too"]
}
''')
fl.close()
print 'Local example.json file created.'

# created jquery.quicksearch.js file
fl=open('./cores/jquery.quicksearch.js','w')
fl.write('''
(function($, window, document, undefined) {
	$.fn.quicksearch = function (target, opt) {

		var timeout, cache, rowcache, jq_results, val = '', e = this, options = $.extend({
			delay: 100,
			selector: null,
			stripeRows: null,
			loader: null,
			noResults: '',
			bind: 'keyup',
			onBefore: function () {
				return;
			},
			onAfter: function () {
				return;
			},
			show: function () {
				this.style.display = "";
			},
			hide: function () {
				this.style.display = "none";
			},
			prepareQuery: function (val) {
				return val.toLowerCase().split(' ');
			},
			testQuery: function (query, txt, _row) {
				for (var i = 0; i < query.length; i += 1) {
					if (txt.indexOf(query[i]) === -1) {
						return false;
					}
				}
				return true;
			}
		}, opt);

		this.go = function () {

			var i = 0,
			noresults = true,
			query = options.prepareQuery(val),
			val_empty = (val.replace(' ', '').length === 0);

			for (var i = 0, len = rowcache.length; i < len; i++) {
				if (val_empty || options.testQuery(query, cache[i], rowcache[i])) {
					options.show.apply(rowcache[i]);
					noresults = false;
				} else {
					options.hide.apply(rowcache[i]);
				}
			}

			if (noresults) {
				this.results(false);
			} else {
				this.results(true);
				this.stripe();
			}

			this.loader(false);
			options.onAfter();

			return this;
		};

		this.stripe = function () {

			if (typeof options.stripeRows === "object" && options.stripeRows !== null)
			{
				var joined = options.stripeRows.join(' ');
				var stripeRows_length = options.stripeRows.length;

				jq_results.not(':hidden').each(function (i) {
					$(this).removeClass(joined).addClass(options.stripeRows[i % stripeRows_length]);
				});
			}

			return this;
		};

		this.strip_html = function (input) {
			var output = input.replace(new RegExp('<[^<]+\>', 'g'), "");
			output = $.trim(output.toLowerCase());
			return output;
		};

		this.results = function (bool) {
			if (typeof options.noResults === "string" && options.noResults !== "") {
				if (bool) {
					$(options.noResults).hide();
				} else {
					$(options.noResults).show();
				}
			}
			return this;
		};

		this.loader = function (bool) {
			if (typeof options.loader === "string" && options.loader !== "") {
				 (bool) ? $(options.loader).show() : $(options.loader).hide();
			}
			return this;
		};

		this.cache = function () {

			jq_results = $(target);

			if (typeof options.noResults === "string" && options.noResults !== "") {
				jq_results = jq_results.not(options.noResults);
			}

			var t = (typeof options.selector === "string") ? jq_results.find(options.selector) : $(target).not(options.noResults);
			cache = t.map(function () {
				return e.strip_html(this.innerHTML);
			});

			rowcache = jq_results.map(function () {
				return this;
			});

			return this.go();
		};

		this.trigger = function () {
			this.loader(true);
			options.onBefore();

			window.clearTimeout(timeout);
			timeout = window.setTimeout(function () {
				e.go();
			}, options.delay);

			return this;
		};

		this.cache();
		this.results(true);
		this.stripe();
		this.loader(false);

		return this.each(function () {
			$(this).bind(options.bind, function () {
				val = $(this).val();
				e.trigger();
			});
		});
	};
}(jQuery, this, document));
''')
fl.close()
print 'Local jquery.quicksearch.js file created.'


# upload the whole local folder ./cores to a github repository
# note that each local project will be uploaded in a separate branch
if github_upload != True:
    sys.exit(0)

# quickly analyze local folder structure and extract all project names
if os.path.isdir('./cores')==False:
    print 'Local ./cores folder does not exist.'
    sys.exit(0)

prj_categ = next(os.walk('./cores'))[1]
prjs = []
empty_prjs = 0
for x in prj_categ:
    _path = './cores/'+ x
    for y in next(os.walk(_path))[1]:
        # get only projects with a tar.gz file in it (not empty)
        z = os.listdir(_path+"/"+y)
        for elem in z:
            if elem.endswith(".tar.gz"):
                prjs.append([[x],[y]])
                break

    #no prjs stores both categories and projects
    print "Number of local non empty projects: ", len(prjs)

    # create a fresh git repository
    if len(prjs)==0:
        print 'No projects available locally'
        sys.exit(0)

    # FROM THIS POINT ON THE CODE IS UNTESTED #

    # unzip project files and move them in its prj folder
    for x in prjs:
        prj_cat = x[0][0]
        prj_name = x[1][0]
        z = os.listdir('./cores/'+prj_cat+'/'+prj_name+'/')
        for _fl in z:
            if _fl.endswith('.tar.gz'):
                tfile = tarfile.open('./cores/'+prj_cat+'/'+prj_name+'/'+_fl, 'r:gz')
                tfile.extractall('./cores/'+prj_cat+'/'+prj_name+'/')
                os.system('mv ./cores/'+prj_cat+'/'+prj_name+'/'+_fl[:-7]+'/trunk/* ./cores/'+prj_cat+'/'+prj_name+'/')
                os.system('rm ./cores/'+prj_cat+'/'+prj_name+'/'+_fl)      # remove tar.gz file
                os.system('rm -Rf ./cores/'+prj_cat+'/'+prj_name+'/'+_fl[:-7]) # remove original unzipped folder

    # proceed with git
    os.chdir('./cores')
    os.system('rm -Rf ./git_dir') # delete current git master project

    # download (locally) only master branch from the defaul github repository that
    # you specified at the beginning of this file
    os.system('git clone --depth=1 ' + _github_addr + ' git_dir')
    os.chdir('./git_dir')

    # create a new branch per project. Copy the project content in it.
    for x in prjs:
        prj_cat = x[0][0]
        prj_name = x[1][0]
        os.system('git checkout --orphan ' + prj_name + ' >/dev/null') # create new indipended branch
        os.system('git rm --cached -r .'+ ' >/dev/null') # empty the new branch

        _txt="echo Project Category: "+prj_cat+", Project Name: "+prj_name+" > INFO.txt"
        os.system(_txt)

        os.system('cp -Rf ../'+ prj_cat +'/'+ prj_name +'/* ./') # add project into branch

        os.system('git add .') # add project into branch
        os.system("git commit -m 'added content for project'") # add project into branch


    # upload one by one all branches to github
    for x in prjs:
        prj_name = x[1][0]
        os.system('git checkout ' + prj_name)
        os.system('git checkout ' + prj_name) git push origin --all
        # manually enter login and password
