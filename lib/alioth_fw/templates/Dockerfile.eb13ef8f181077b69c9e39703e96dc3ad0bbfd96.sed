s|^\(RUN git clone https://github.com/ssut/payload-dumper-go\)$|\1 \&\& git -C payload-dumper-go checkout eb13ef8f181077b69c9e39703e96dc3ad0bbfd96|
s|^\(FROM alpine\)$|\1 as dumper|
$a\
ADD {{ fw_url }} fw.zip\
RUN mkdir /fw_files && /go/bin/payload-dumper-go -o /fw_files fw.zip\
\
FROM scratch\
COPY --from=dumper /fw_files/* /
