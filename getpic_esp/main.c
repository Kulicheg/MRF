#include <ctype.h>
#include <math.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <oscalls.h>
#include <osfs.h>
#include <intrz80.h>
#include <terminal.c>
#include <graphic.h>

#define RBR_THR 0xF8EF
#define IER 0xF9EF
#define IIR_FCR 0xFAEF
#define LCR 0xFBEF
#define MCR 0xFCEF
#define LSR 0xFDEF
#define MSR 0xFEEF
#define SR 0xFFEF

struct fileStruct
{
  long picId;
  unsigned int picYear;
  unsigned long totalAmount;
  unsigned char picRating[8];
  unsigned char picName[256];
  unsigned char picType[64];
  unsigned char authorIds[64];
  unsigned char authorTitle[64];
  unsigned char authorRealName[64];
  unsigned char afn[128];
  unsigned char pfn[128];
  unsigned char fileName[128];
} curFileStruct;
unsigned char ver[] = "2.1 ESP";
unsigned char scratch[256];
unsigned char netbuf[2048];
unsigned char picture[16384];
unsigned char crlf[2] = {13, 10};
unsigned long bytecount;
unsigned char status, keypress, verbose, randomPic, slideShow;
unsigned long contLen, countPic;
unsigned int headlng, slideShowTime = 0;
unsigned char skipHeader, socket = 1;
unsigned int packSize = 2000;
unsigned char CIPRECVDATA;
unsigned int loaded;
void emptyKeyBuf(void)
{
  do
  {
  } while (_low_level_get() != 0);
}

void printHelp(void)
{
  ATRIB(95);
  printf("   GETPIC [%s] zxart.ee picture viewer for nedoNET\n\r", ver);
  ATRIB(33);
  ATRIB(40);
  printf("-------------------------------------------------------\n\r");
  printf(" Управление:\n\r");
  printf(" 'ESC' - выход из программы;\n\r");
  printf(" '<-' или 'B' к последним картинкам;\n\r");
  printf(" '->' или 'Пробел' к более старым картинкам\n\r");
  printf(" 'J' Прыжок на  указанную по счету картинку\n\r");
  printf(" 'I' Просмотр экрана информации о картинках\n\r");
  printf(" 'S' Сохранить картинку на диск в текущую папку\n\r");
  printf(" 'V' не выводить информацию об авторах\n\r");
  printf(" 'R' переход в режим  случайная картинка с рейтингом 4+\n\r");
  printf(" 'A' переход в режим  слайд-шоу\n\r");
  printf(" 'H' Данная справочная информация\n\r");
  printf("-----------------Нажмите любую кнопку------------------\n\r");
  ATRIB(93);
  do
  {
    YIELD();
    keypress = _low_level_get();
  } while (keypress == 0);
  emptyKeyBuf();
}
void delay(unsigned long counter)
{
  unsigned long start, finish;
  counter = counter / 20;
  if (counter < 1)
  {
    counter = 1;
  }
  start = time();
  finish = start + counter;

  while (start < finish)
  {
    start = time();
  }
}

void uart_init(unsigned char divisor)
{
  output(MCR, 0x00);        // Disable input
  output(IIR_FCR, 0x87);    // Enable fifo 8 level, and clear it
  output(LCR, 0x83);        // 8n1, DLAB=1
  output(RBR_THR, divisor); // 115200 (divider 1-115200, 3 - 38400)
  output(IER, 0x00);        // (divider 0). Divider is 16 bit, so we get (#0002 divider)
  output(LCR, 0x03);        // 8n1, DLAB=0
  output(IER, 0x00);        // Disable int
}

void uart_write(unsigned char data)
{
  while ((input(LSR) & 64) == 0)
  {
  }
  output(RBR_THR, data);
}

void uart_setrts(unsigned char mode)
{
  switch (mode)
  {
  case 1:
    output(MCR, 2);
    break;
  case 0:
    output(MCR, 0);
    break;
  default:
    disable_interrupt();
    output(MCR, 2);
    output(MCR, 0);
    enable_interrupt();
  }
}

unsigned char uart_hasByte(void)
{
  return (1 & input(LSR));
}

unsigned char uart_read(void)
{
  return input(RBR_THR);
}

unsigned char uart_readBlock(void)
{
  uart_setrts(2);
  while (uart_hasByte() == 0)
  {
  }
  return input(RBR_THR);
}

void uart_flush(void)
{
  unsigned int count;
  for (count = 0; count < 6000; count++)
  {
    uart_setrts(2);
    uart_read();
  }
  printf("\r\nBuffer cleared.\r\n");
}

void getdata(unsigned int counted)
{
  unsigned int counter;
  for (counter = 0; counter < counted; counter++)
  {
    netbuf[counter] = uart_readBlock();
    // putchar(netbuf[counter]);
  }
  netbuf[counter] = '\0';
}

void sendcommand(char *commandline)
{
  unsigned int count;
  strcpy(scratch, commandline);
  for (count = 0; count < strlen(scratch); count++)
  {
    uart_write(scratch[count]);
    putchar(scratch[count]);
  }
  uart_write('\r');
  uart_write('\n');
  printf("\r\n");
  while ((input(LSR) & 32) == 0)
  {
  }
  delay(250);
}

unsigned char getAnswer(unsigned char skip)
{
  unsigned char readbyte;
  unsigned int curPos = 0;
  while (skip != 0)
  {
    uart_readBlock();
    skip--;
    putchar('#');
  }
  while (42)
  {
    readbyte = uart_readBlock();
    if (readbyte == 0x0a)
    {
      break;
    }
    netbuf[curPos] = readbyte;
    curPos++;
  }
  netbuf[curPos] = 0;
  // printf("=>");
  puts(netbuf);
  puts("\r\n");
  YIELD();
  delay(100);
  return curPos;
}

void reBoot(void)
{
  unsigned char byte;
  sendcommand("AT+RST");
  uart_flush();
  puts("Resetting ESP...\r\n");
  delay(2000);
  byte = 0;
  while (byte != 'P')
  {
    byte = uart_readBlock();
    // putchar(byte);
  }
  uart_readBlock(); // CR
  uart_readBlock(); // LN
  puts("\r\n");

  sendcommand("ATE0");
  getAnswer(0); // ATE0
  getAnswer(2); // OK
  sendcommand("AT+CIPCLOSE");
  getAnswer(2);
  sendcommand("AT+CIPDINFO=0");
  getAnswer(2);
  sendcommand("AT+CIPMUX=0");
  getAnswer(2);
  sendcommand("AT+CIPSERVER=0");
  getAnswer(2);
  sendcommand("AT+CIPRECVMODE=1");
  getAnswer(2);
}

unsigned int recvHead(void)
{
  unsigned char byte, dataRead;
  while (byte != ',')
  {
    byte = uart_readBlock();
    netbuf[dataRead] = byte;
    dataRead++;
  }
  loaded = atoi(netbuf + 13); // <actual_len>
  CIPRECVDATA = dataRead - 1;
  return loaded;
}

unsigned int httpError(void)
{
  unsigned char *httpRes;
  unsigned int httpErr;
  httpRes = strstr(netbuf, "HTTP/1.1 ");

  if (httpRes != NULL)
  {
    httpErr = atol(httpRes + 9);
  }
  else
  {
    httpErr = 0;
  }
  return httpErr;
}

unsigned int cutHeader2(unsigned int todo)
{
  unsigned int recAmount, err;
  unsigned char *count1;

  err = httpError();
  printf("\r\nHTTP response:[%u]\r\n", err);
  delay(500);
  if (err != 200)
  {
    printf("^^^^^^^^^^^^^^^^^^^^^\r\n");
    puts(netbuf);
    getchar();
  }
  count1 = strstr(netbuf, "Content-Length:");
  if (count1 == NULL)
  {
    printf("contLen  not found \r\n");
    contLen = 0;
  }
  else
  {
    contLen = atol(count1 + 15);
    printf("Content-Length: %lu \n\r", contLen);
  }

  count1 = strstr(netbuf, "\r\n\r\n");
  if (count1 == NULL)
  {
    printf("header not found\r\n");
  }
  else
  {
    headlng = ((unsigned int)count1 - (unsigned int)netbuf + 4);
    recAmount = todo - headlng;
    printf("header %u bytes\r\n", headlng);
    skipHeader = 1;
  }
  return recAmount;
}

// in netbuf data to send
unsigned int fillPictureEsp(unsigned char socket)
{
  unsigned char cmd[256];
  unsigned char link[256];
  unsigned char sizeLink;
  unsigned long toDownload, downloaded;
  unsigned char byte;
  unsigned int dataSize;
  socket = 1;
  strcpy(link, netbuf);
  strcat(link, "\r\n");
  sizeLink = strlen(link);
  delay(500);
  sendcommand("AT+CIPSTART=\"TCP\",\"zxart.ee\",80");
  delay(500);
  getAnswer(0); // CONNECT
  getAnswer(2); // OK
  strcpy(cmd, "AT+CIPSEND=");
  sprintf(scratch, "%u", sizeLink + 2); // second CRLF in send command
  strcat(cmd, scratch);
  sendcommand(cmd);
  byte = 0;
  while (byte != '>')
  {
    byte = uart_readBlock();
    putchar(byte);
  }
  puts(">>>");
  sendcommand(link);
  getAnswer(2); // Recv 132 bytes
  getAnswer(2); // SEND OK
  getAnswer(2); //+IPD,3872

  toDownload = 42;
  skipHeader = 0;
  downloaded = 0;
  while (toDownload > 0)
  {
    headlng = 0;
    sprintf(scratch, "%u", packSize);
    strcpy(netbuf, "AT+CIPRECVDATA=");
    strcat(netbuf, scratch);
    sendcommand(netbuf);
    dataSize = recvHead();
    getdata(dataSize); // Requested size
    if (skipHeader == 0)
    {
      dataSize = cutHeader2(dataSize);
      toDownload = contLen;
    }
    downloaded = downloaded + dataSize;
    memcpy(picture + downloaded - dataSize, netbuf + headlng, dataSize);
    toDownload = toDownload - dataSize;
    getAnswer(2); // OK
    if (toDownload > 0)
    {
      getAnswer(2); // +IPD,1824 // ipdSize = atoi(netbuf + 5);
    }
  }
  sendcommand("AT+CIPCLOSE");
  getAnswer(2);
  getAnswer(0); // CLOSED

  printf("Done!\r\n");
  return 0;
}

char *str_replace(char *dst, int num, const char *str,
                  const char *orig, const char *rep)
{
  const char *ptr;
  size_t len1 = strlen(orig);
  size_t len2 = strlen(rep);
  char *tmp = dst;

  num -= 1;
  while ((ptr = strstr(str, orig)) != NULL)
  {
    num -= (ptr - str) + len2;
    if (num < 1)
      break;

    strncpy(dst, str, (size_t)(ptr - str));
    dst += ptr - str;
    strncpy(dst, rep, len2);
    dst += len2;
    str = ptr + len1;
  }

  for (; (*dst = *str) && (num > 0); --num)
  {
    ++dst;
    ++str;
  }
  return tmp;
}

void nameRepair(unsigned char *pfn, unsigned int tfnSize)
{

  str_replace(pfn, tfnSize, pfn, "\\", "_");
  str_replace(pfn, tfnSize, pfn, "/", "_");
  str_replace(pfn, tfnSize, pfn, ":", "_");
  str_replace(pfn, tfnSize, pfn, "*", "_");
  str_replace(pfn, tfnSize, pfn, "?", "_");
  str_replace(pfn, tfnSize, pfn, "<", "_");
  str_replace(pfn, tfnSize, pfn, ">", "_");
  str_replace(pfn, tfnSize, pfn, "|", "_");
  str_replace(pfn, tfnSize, pfn, " ", "_");
  str_replace(pfn, tfnSize, pfn, "&#039;", "'");
  str_replace(pfn, tfnSize, pfn, "&amp;", "&");
  str_replace(pfn, tfnSize, pfn, "&quot;", "'");
  str_replace(pfn, tfnSize, pfn, "&gt;", ")");
  str_replace(pfn, tfnSize, pfn, "&lt;", "(");
  str_replace(pfn, tfnSize, pfn, "\"", "'");
}

void stringRepair(unsigned char *pfn, unsigned int tSize)
{
  str_replace(pfn, tSize, pfn, "&#039;", "'");
  str_replace(pfn, tSize, pfn, "&amp;", "&");
  str_replace(pfn, tSize, pfn, "&gt;", ">");
  str_replace(pfn, tSize, pfn, "&lt;", "<");
  str_replace(pfn, tSize, pfn, "&quot;", "\"");
  str_replace(pfn, tSize, pfn, "\\/", "/");
}

unsigned char getPic(unsigned long fileId)
{
  unsigned char buffer[] = "0000000000";
  netbuf[0] = '\0';
  sprintf(buffer, "%lu", fileId);
  strcat(netbuf, "GET /file/id:");
  strcat(netbuf, buffer);
  strcat(netbuf, " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: User-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS)\r\n\r\n\0");
  fillPictureEsp(socket);
  return 0;
}
unsigned char savePic(unsigned long fileId)
{
  FILE *fp2;
  unsigned char afnSize, tfnSize;
  unsigned char fileIdChar[10];

  afnSize = sizeof(curFileStruct.afn) - 1;
  tfnSize = sizeof(curFileStruct.pfn) - 1;

  strcpy(curFileStruct.afn, curFileStruct.authorTitle);
  nameRepair(curFileStruct.afn, afnSize);

  strcpy(curFileStruct.pfn, curFileStruct.picName);
  nameRepair(curFileStruct.pfn, tfnSize);

  sprintf(curFileStruct.fileName, "%s-%s-%ld.scr", curFileStruct.afn, curFileStruct.pfn, fileId);
  if (strlen(curFileStruct.fileName) > 62)
  {
    sprintf(fileIdChar, "-%ld", fileId);
    str_replace(curFileStruct.fileName, sizeof(curFileStruct.fileName) - 1, curFileStruct.fileName, fileIdChar, "");
    curFileStruct.fileName[50] = '\0';
    strcat(curFileStruct.fileName, fileIdChar);
    strcat(curFileStruct.fileName, ".scr");
  }
  OS_SETSYSDRV();
  OS_MKDIR("../downloads");        // Create if not exist
  OS_MKDIR("../downloads/getpic"); // Create if not exist
  OS_CHDIR("../downloads/getpic");
  fp2 = OS_CREATEHANDLE(curFileStruct.fileName, 0x80);
  if (((int)fp2) & 0xff)
  {
    printf(curFileStruct.fileName);
    printf(" creating error\r\n");
    getchar();
    exit(0);
  }
  OS_WRITEHANDLE(picture, fp2, 6912);
  OS_CLOSEHANDLE(fp2);
  return 0;
}

int pos(unsigned char *s, unsigned char *c, unsigned int n, unsigned int startPos)
{
  unsigned int i, j;
  unsigned int lenC, lenS;

  for (lenC = 0; c[lenC]; lenC++)
    ;
  for (lenS = 0; s[lenS]; lenS++)
    ;

  for (i = startPos; i <= lenS - lenC; i++)
  {
    for (j = 0; s[i + j] == c[j]; j++)
      ;

    if (j - lenC == 1 && i == lenS - lenC && !(n - 1))
      return i;
    if (j == lenC)
      if (n - 1)
        n--;
      else
        return i;
  }
  return -1;
}

const char *parseJson(unsigned char *property)
{
  unsigned int w, lng, lngp1, findEnd, listPos;
  unsigned char terminator;
  int n;
  n = -1;
  netbuf[0] = '\0';
  n = pos(picture, property, 1, 0);
  if (n == -1)
  {
    strcpy(netbuf, "-");
    // printf("Property %s not found", property);
    return netbuf;
  }
  lng = n - 1 + strlen(property);
  if (picture[lng] == ':')
  {
    terminator = '\0';
  }
  if (picture[lng] == '\"')
  {
    terminator = '\"';
  }
  if (picture[lng] == '[')
  {
    terminator = ']';
  }

  findEnd = 1;
  lngp1 = lng + 1;

  while (42)
  {

    if ((picture[lngp1 + findEnd] == ','))
    {
      if (terminator == '\0')
      {
        break;
      }
      if ((picture[lng + findEnd] == terminator))
      {
        findEnd--;
        break;
      }
    }
    findEnd++;
  }
  listPos = 0;
  for (w = lngp1; w < findEnd + lngp1; w++)
  {
    netbuf[listPos] = picture[w];
    listPos++;
  }
  netbuf[listPos] = '\0';
  return netbuf;
}
void convert866(void)
{
  unsigned int lng, targetPos, w, q = 0;
  unsigned char buffer[8], one, two;
  unsigned int decVal;
  lng = strlen(netbuf);
  targetPos = lng + 1;

  while (q < lng)
  {
    one = netbuf[q];
    two = netbuf[q + 1];
    if (one == 92 && two == 117)
    {
      q = q + 2;
      for (w = 0; w < 4; w++)
      {
        buffer[w] = netbuf[q + w];
      }
      q = q + 4;
      buffer[4] = '\0';
      decVal = (unsigned int)strtol(buffer, NULL, 16);

      if (decVal < 1088)
      {
        decVal = decVal - 912;
      }
      if (decVal > 1087)
      {
        decVal = decVal - 864;
      }
      if (decVal == 1025)
      {
        decVal = 240;
      }
      if (decVal == 1105)
      {
        decVal = 241;
      }
      netbuf[targetPos] = decVal;
    }
    else
    {
      netbuf[targetPos] = netbuf[q];
      q++;
    }
    targetPos++;
  }
  netbuf[targetPos] = '\0';

  for (w = lng + 1; w < targetPos + 1; w++)
  {
    netbuf[w - lng - 1] = netbuf[w];
  }
}

unsigned long processJson(unsigned long startPos, unsigned char limit, unsigned char queryNum)
{
  unsigned int retry, tSize;
  unsigned int pPos, headskip;
  unsigned char buffer[] = "000000000";
  unsigned char *count, socket;
  unsigned char userAgent[] = " HTTP/1.1\r\nHost: zxart.ee\r\nUser-Agent: Mozilla/4.0 (compatible; MSIE5.01; NedoOS; GetPic)\r\n\r\n\0";
  retry = 10;
  startPos = 888;
  switch (queryNum)
  {
  case 0:
    strcpy(netbuf, "GET /api/export:zxPicture/filter:zxPictureType=standard/limit:");
    sprintf(buffer, "%u", limit);
    strcat(netbuf, buffer);
    strcat(netbuf, "/start:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, "/order:date,desc");
    strcat(netbuf, userAgent);
    break;

  case 1:
    strcpy(netbuf, "GET /api/types:zxPicture/export:zxPicture/language:eng/start:0/limit:1/order:rand/filter:zxPictureMinRating=4;zxPictureType=standard");
    strcat(netbuf, userAgent);
    break;

  case 3: // /api/export:author/filter:authorId=2202
    strcpy(netbuf, "GET /api/export:author/filter:authorId=");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
    break;

  case 99: // GET /jsonElementData/elementId:182798
    strcpy(netbuf, "GET /jsonElementData/elementId:");
    sprintf(buffer, "%lu", startPos);
    strcat(netbuf, buffer);
    strcat(netbuf, userAgent);
    break;
  }

rejson:
  headskip = 0;
  pPos = 0;
  fillPictureEsp(socket);

  count = strstr(picture, "responseStatus\":\"success");
  if (count == NULL)
  {
    ATRIB(91);
    printf("BAD JSON, NO responseStatus: success. %u   \r\n", retry);
    retry--;
    YIELD();
    if (retry > 0)
      goto rejson;
    return -1;
  }

  count = strstr(picture, "\"id\":");
  if (count == NULL)
  {
    ATRIB(91);
    printf("BAD JSON: ID not found.\r\n");
    return -2;
  }

  netbuf[0] = '\0';
  if (queryNum < 3)
  {
    parseJson("\"id\":");
    curFileStruct.picId = atol(netbuf);
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.picName, netbuf);

    tSize = sizeof(curFileStruct.picName);
    stringRepair(curFileStruct.picName, tSize);

    parseJson(",\"type\":\"");
    strcpy(curFileStruct.picType, netbuf);
    parseJson("\"rating\":\"");
    strcpy(curFileStruct.picRating, netbuf);
    parseJson("\"year\":\"");
    curFileStruct.picYear = atoi(netbuf);
    parseJson("\"totalAmount\":");
    curFileStruct.totalAmount = atol(netbuf);
    parseJson("\"authorIds\":[");
    strcpy(curFileStruct.authorIds, netbuf);
  }
  if (queryNum == 99)
  {
    parseJson(",\"title\":\"");
    convert866();
    strcpy(curFileStruct.authorTitle, netbuf);
    parseJson(",\"realName\":\"");
    convert866();
    strcpy(curFileStruct.authorRealName, netbuf);
  }
  return curFileStruct.picId;
}

void printData(unsigned long counter)
{
  ATRIB(93);
  printf(" #: ");
  ATRIB(97);
  printf("%lu", counter);
  ATRIB(93);
  printf(" ID: ");
  ATRIB(97);
  printf("%lu ", curFileStruct.picId);
  ATRIB(93);
  printf(" Total Pics: ");
  ATRIB(97);
  printf("%lu \r\n", curFileStruct.totalAmount);
  ATRIB(93);
  printf(" Author: ");
  ATRIB(96);
  printf("%s\r\n", curFileStruct.authorTitle);
  ATRIB(93);
  printf(" TITLE: ");
  ATRIB(95);
  printf("%s\r\n", curFileStruct.picName);
  ATRIB(93);
  printf(" RATING: ");
  ATRIB(97);
  printf("%s", curFileStruct.picRating);
  ATRIB(93);
  printf(" YEAR: ");
  ATRIB(97);
  printf("%u", curFileStruct.picYear);
  printf(" \r\n");
  ATRIB(93);
  printf(" AuthorsIDs ");
  ATRIB(97);
  printf("%s", curFileStruct.authorIds);
  ATRIB(93);
  printf(" Real name: ");
  ATRIB(97);
  printf("%s", curFileStruct.authorRealName);
  printf(" \r\n");
  ATRIB(96);
  printf(" \r\n");
}
void safeKeys(unsigned char keypress)
{
  if (keypress == 27)
  {
    printf("Good bye...\r\n");
    ATRIB(37);
    ATRIB(40);
    exit(0);
  }

  if (keypress == 'j' || keypress == 'J')
  {
    printf("Jump to picture:");
    scanf("%lu", &countPic);
    if (countPic > curFileStruct.totalAmount - 1)
    {
      countPic = curFileStruct.totalAmount - 1;
    }
  }

  if (keypress == 'v' || keypress == 'V')
  {
    verbose = !verbose;

    if (verbose == 0)
    {
      BOX(1, 1, 80, 25, 40);
      AT(1, 1);
    }
  }

  if (keypress == 'h' || keypress == 'H')
  {
    printHelp();
  }

  if (keypress == 'r' || keypress == 'R')
  {
    randomPic = !randomPic;

    if (verbose == 1)
    {
      if (randomPic == 1)
      {
        printf("    Random mode enabled...\r\n");
      }
      else
      {
        printf("    Sequental mode enabled...\r\n");
      }
    }
  }
  if (keypress == 'a' || keypress == 'A')
  {
    slideShow = !slideShow;
    if (slideShow == 1)
    {
      if (verbose == 1)
        printf("    SlideShow mode enabled...\r\n\r\n");
      slideShowTime = 250;
    }
    else
    {
      if (verbose == 1)
        printf("    Manual mode enabled...\r\n\r\n");
      slideShowTime = 0;
    }
  }
}

C_task main(void)
{
  unsigned char errno;
  unsigned long ipadress;
  long iddqd, idkfa;

  os_initstdio();
  uart_init(1);
  reBoot();

  countPic = 0;
  verbose = 1;
  randomPic = 0;
  slideShow = 0;

  BOX(1, 1, 80, 25, 40);
  AT(1, 1);
  printHelp();
  safeKeys(keypress);

start:
  emptyKeyBuf();
  switch (randomPic)
  {
  case 0:
    iddqd = processJson(countPic, 1, 0);
    break;
  case 1:
    iddqd = processJson(0, 1, 1);
    break;
  }

  if (iddqd < 0)
  {
    countPic++;
    goto start;
  }
  if (verbose == 0)
  {
    idkfa = processJson(atol(curFileStruct.authorIds), 0, 99);
    if (idkfa < 0)
    {
      printf(" Cant parse curFileStruct.authorIds = %s \r\n\r\n", curFileStruct.authorIds);
      countPic++;
      goto start;
    }
  }
  if (verbose == 1)
  {
    printData(countPic);
  }
  else
  {
    // ATRIB(97);
    // printf(" Getting picture...\r\n");
  }
  if (!strcmp(curFileStruct.picType, "standard"))

  {
    errno = getPic(iddqd);

  review:
    keypress = viewScreen6912((unsigned int)&picture, slideShowTime);
    emptyKeyBuf();
  }
  else
  {
    printf("  >>Format %s not supported, skipped \n\r", curFileStruct.picType);
    countPic++;
    goto start;
  }

  ///// Keys only for pictures
  if (keypress == 's' || keypress == 'S')
  {
    savePic(iddqd);
    if (verbose == 1)
      printf("        ID:%lu    TITLE:%s  SAVED\r\n\r\n", curFileStruct.picId, curFileStruct.picName);
    countPic++;
  }

  if (keypress == 248 || keypress == 'b' || keypress == 'B')
  {
    if (countPic > 0)
    {
      countPic--;
    }
  }
  if (keypress == 251 || keypress == 32)
  {
    countPic++;
    goto start;
  }
  if (keypress == 'i' || keypress == 'I')
  {
    do
    {
      YIELD();
    } while (_low_level_get() == 0);
    emptyKeyBuf();
    goto review;
  }
  safeKeys(keypress);
  goto start;
}
