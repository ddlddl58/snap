from subprocess import Popen, PIPE

# Here are the email package modules we'll need
from email.mime.image import MIMEImage
from email.mime.multipart import MIMEMultipart

import getpass
import glob
import os

def sendPngsFromDir(subject, body, dir):
    '''send all *.png images from the dir to myself'''
    # Create the container (outer) email message.
    mailuser = "{}@met.no".format(getpass.getuser())
    msg = MIMEMultipart()
    msg['Subject'] = subject
    msg['From'] = mailuser
    msg['To'] = mailuser
    msg.preamble = body

    for file in glob.glob(os.path.join(dir, '*.png')):
        # Open the files in binary mode.  Let the MIMEImage class automatically
        # guess the specific image type.
        with open(file, 'rb') as fp:
            img = MIMEImage(fp.read())
        msg.attach(img)

    # Send the email via sendmail
    p = Popen(["/usr/sbin/sendmail", "-t", "-oi"], stdin=PIPE)
    p.communicate(msg.as_bytes())
