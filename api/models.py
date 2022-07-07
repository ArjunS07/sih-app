import uuid

from django.db import models

from accounts.models import School, Student, Tutor

class Tutorship(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tutor = models.OneToOneField(Tutor, null=True, on_delete=models.SET_NULL)
    student = models.OneToOneField(Student, null=True, on_delete=models.SET_NULL)

    @property
    def tutorship_s3_folder_path(self):
        pass

class Message(models.Model):
    room = models.ForeignKey(Tutorship, on_delete=models.CASCADE)
    time_sent = models.DateTimeField(auto_now=True)
    text = models.CharField(max_length=2048)

    # Link to prefix on S3 for attachments. This will allow us to store the folder URL directly and download all keys from that folder
    attachments_key_prefix = models.CharField(max_length=256)

    @property
    def has_attachment(self) -> bool:
        return self.attachments_key_prefix != None

class Meeting(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    tutorship = models.ForeignKey(Tutorship, on_delete=models.SET_NULL)
    scheduled_time = models.DateTimeField()

    zoom_invite = models.TextField()

    # TODO: Generate and store zoom invite on being created
    def generate_zoom_invite(self):
        pass

    # TODO: Upload recording to S3 once invite done
    def upload_recording(self):
        pass

    @property
    def s3_record_path(self) -> str:
        # Returns the absolute root path in the format {constants.TUTORSHIP_ROOT}/{tutorshipfolder}/{recordings}/{recordingID}
        path = f'{self.tutorship.tutorship_s3_folder_path}/recordings/{self.id}.mp4' #TODO: Filetypes
