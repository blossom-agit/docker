# Generated by Django 3.2.12 on 2022-02-20 18:24

import cvat.apps.engine.models
from django.db import migrations, models


class Migration(migrations.Migration):

    dependencies = [
        ('engine', '0050_auto_20220211_1425'),
    ]

    operations = [
        migrations.RemoveField(
            model_name='jobcommit',
            name='message',
        ),
        migrations.RemoveField(
            model_name='jobcommit',
            name='version',
        ),
        migrations.AddField(
            model_name='jobcommit',
            name='data',
            field=models.JSONField(default=dict, encoder=cvat.apps.engine.models.Commit.JSONEncoder),
        ),
        migrations.AddField(
            model_name='jobcommit',
            name='scope',
            field=models.CharField(default='', max_length=32),
        ),
    ]
