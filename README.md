# callowayart-migration

## Introduction

Provides automation of callowayart-migration process with brandefined's work
on wordpress

## Requirements

1\. Docker version 17.06.0-ce, build 02c1d87
2\. aws-cli/1.11.123 Python/2.7.13 Darwin/16.3.0 botocore/1.5.86

## Instructions

1\. Set appropriate aws profile
```bash
export AWS_PROFILE=callowayart
```

2\. Install build dependencies
```bash
make
```

3\. Build images
```bash
make build
```

4\. Finally, release application (note: binds on 80)
```bash
make release
```

## Caveats

If you're not me :), you'll need to contact me for appropriate secrets callowaylc@gmail.com