#!/usr/bin/python3

from imapclient import imap_utf7
import imaplib
import time
from threading import Thread
import threading
import os


def getSep(folders):
    string = str(folders[0])
    sep = string.find(') "')+3
    sep = string[sep:sep+1]
    return sep


def download(mail):
    m1 = imaplib.IMAP4_SSL(mail[2], mail[3])
    m1.login(mail[0], mail[1])
    status, folders = m1.list()
    nf = 0
    sep = getSep(folders)
    folders_list = []
    for f in folders:
        nf += 1
        f8 = imap_utf7.decode(f)
        f7 = str(f)
        folder8 = f8.split(' "'+sep+'" ')[1].replace('"','').replace("'",'')
        folder7 = f7.split(' "'+sep+'" ')[1].replace('"','').replace("'",'')
        print('{0:5}. Flolder8: {1:30} Flolder7: {2:50}'.format(nf,folder8,folder7))
        folders_list.append([folder7,folder8])
    for f in folders_list:
        try:
            os.makedirs('./'+ mail[0] + '/mail/' + f[1])
        except:
            print('error create folder: {}'.format('./'+ mail[0] + '/mail/' + f[1]))
        m1.select(f[0])
        typ, data = m1.uid('search', None, 'ALL')
        if typ == 'OK':
            msgs = data[0].split()
            i = 1
            mail_count = len(msgs)
            for num in msgs:
                num = int(num)
                testpath = './'+ mail[0] + '/mail/' + f[1] + '/' + str(num)
                if not os.path.isfile(testpath):
                    thread = DownloadThread(mail, num, f)
                    thread.start()
                    while(threading.active_count() > 100):
                        time.sleep(0.5)
                i +=1
                print('{0:^10} -> {1:^10}'.format(i,mail_count))


class DownloadThread(Thread):
        def __init__(self, mail, num, folder):
            Thread.__init__(self)
            self.mail = mail
            self.num = num
            self.folder = folder

        def run(self):
            m1 = imaplib.IMAP4_SSL(self.mail[2], self.mail[3])
            m1.login(self.mail[0], self.mail[1])
            m1.select(self.folder[0])
            typ, data = m1.uid('fetch', str(self.num), '(RFC822 FLAGS)')
            if typ == 'OK':
                flag = getFlags(data[1])
                print('Message _____{:^10} download OK'.format(self.num))
                if data[0][1]:
                    try:
                        with open( './' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num), 'wb') as f:
                                f.write(data[0][1])
                        with open( './' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num)+'.flag', 'w') as f:
                                f.write(flag)
                    except:
                        if os.path.exists('./' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num)):
                            os.remove('./' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num))
                        if os.path.exists('./' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num)+'.flag'):
                            os.remove('./' + self.mail[0] + '/mail/' + self.folder[1] + '/' + str(self.num)+'.flag')
                        print('save error message # {:^10} data {}'.format(self.num, data[0][1]))


def getFlags(data):
    data=str(data)
    try:
        f_start= data.find('FLAGS (')+len('FLAGS (')
        f_end= data.find(')', f_start)
        flag = data[f_start:f_end]
    except:
        flag = '\\Seen'
    return flag


def getTime(data):
    data=str(data)
    time_start= data.lower().find("\\ndate: ")+len("\\ndate: ")
    time_end= data.find('\\', time_start)
    my_time = data[time_start:time_end].strip().replace('  ',' ')
    dd = False
    if len(my_time.split(' ')) == 6:
        try:
            dd = time.strptime(my_time, "%a, %d %b %Y %H:%M:%S %z")
        except:
            try:
                dd = time.strptime(my_time, "%a, %d %b %Y %H:%M:%S, %z")
            except:
                dd = False
    if not dd:
        try:
            temp = my_time.split(' ')[0:5]
            dd = time.strptime((' ').join(temp) + ' +0300', "%a, %d %b %Y %H:%M:%S %z")
        except:
            temp = my_time.split(' ')
            if -(temp[0].find(',')):
                try:
                    dd = time.strptime((' ').join(temp[0:4]).replace(',','') + ' +0300', "%d %b %Y %H:%M:%S %z")
                except:
                    print((' ').join(temp[0:4]).replace(',',''))
                    print(my_time)
                    dd = False
        if not dd:
            dd = time.time()
    return dd


def upload(mail, mailold):
    m1 = imaplib.IMAP4_SSL(mail[2], mail[3])
    m1.login(mail[0], mail[1])
    folder = './' + mailold + '/mail'
    mail_count = 0
    i = 0
    folder_i = 0
    for the_folder in os.listdir(folder):
        folder_i += 1
        folders_path = os.path.join(folder, the_folder)
        try:
            print(the_folder)
            m1.create(imap_utf7.encode(the_folder))
        except:
            print('folder already exists')
        mail_count = mail_count + int(len(os.listdir(folders_path))/2)
        olddd = time.time()
        try:
            os.makedirs('./' + mailold + '/restore/'+mail[0]+'/'+the_folder)
        except:
            print('error create folder ')
        for the_file in os.listdir(folders_path):
            if not the_file[-5:] =='.flag':
                i += 1
                print(str(i) + '->' + str(mail_count))
                if not os.path.isfile('./' + mailold + '/restore/'+mail[0]+'/'+the_folder+'/'+the_file):
                    thread = uploadThread(mail, mailold, the_folder, the_file)
                    thread.start()
                    while(threading.active_count() > 50):
                        time.sleep(0.1)


class uploadThread(Thread):
        def __init__(self, mail, mailold, folder, file):
            Thread.__init__(self)
            self.mail = mail
            self.folder = folder
            self.mailold = mailold
            self.file = file

        def run(self):
            m1 = imaplib.IMAP4_SSL(self.mail[2], self.mail[3])
            m1.login(self.mail[0], self.mail[1])
            file_path= os.path.join('./' + self.mailold + '/mail/'+self.folder+'/'+self.file)
            with open(file_path,'rb') as f:
                data = f.read()
            message_time = getTime(data)
            try:
                with open(file_path + '.flag','r') as f:
                    flag = f.read()
            except:
                flag = ''
            flag = flag.replace('\\\\','\\')
            typ, data = m1.append(imap_utf7.encode(self.folder), flag, imaplib.Time2Internaldate(message_time), data)
            if typ == 'OK':
                print('OK____________{0:^10}___thread count: {1:^10}'.format(self.file,threading.active_count()))
                with open('./' + self.mailold + '/restore/'+mail[0]+'/'+self.folder+'/'+self.file, 'a') as f:
                    f.write('')


if __name__ == "__main__":
    mail_old = ['user1@test.ru', 'password','imap.mail.ru', 993]
    download(mail_old)
    mail_new = ['user2@test.ru', 'password','imap.mail.ru', 993]
    upload(mail_new, mail_old[0])
