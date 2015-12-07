#include <stdio.h>

int test_func(int x, int y, int z)
{
  printf("%d %d %d\n", x, y, z);
  return 1;
}

/*__declspec(naked) void _cdelc_fcall1(void *func, volatile const void *args, size_t argsz, volatile void *result)
{
  __asm
  {
    pushad
    mov  ebp, esp
    mov  ecx, [ebp+0x2C] ; argsz
    sub  esp, ecx
    shr  ecx, 0x02
    mov  esi, [ebp+0x28] ; args
    mov  edi, esp
    rep  movsd
    mov  eax, [ebp+0x24] ; func
    call eax
    mov  edx, [ebp+0x30] ; result
    mov  [edx], eax
    mov  esp, ebp
    popad
    ret
  }
}*/


void _cdelc_fcall2(void *func, const void *args, size_t argsz, void *result)
{
  /*__asm
  (
    mov  ecx, argsz
    sub  esp, ecx
    shr  ecx, 0x02
    mov  esi, args
    mov  edi, esp
    rep  movsd
    mov  eax, func
    call eax
    mov  edx, result
    mov  [edx], eax
    add  esp, argsz
  )*/
  
  int foo = 10, bar = 15;
  printf("foo=%d, argsz=%d\n", foo, argsz);
  __asm__ __volatile__("mov %1, %%ecx" : "=c"(foo) : "g"(argsz));
    
  printf("foo+bar=%d\n", foo);

}


int main(int argc, char *argv[])
{
  int ret, args[3];
  
  args[0] = 10;
  args[1] = 20;
  args[2] = 30;
  
  // ret = test_func(args[0], args[1], args[2]);
  // printf("ret = %d\n", ret);
  
  // reset ret just to to make sure we change the value
  ret = 0;
  
  //_cdelc_fcall1(test_func, args, sizeof(args), &ret);
  // printf("ret = %d\n", ret);
  
  // reset ret just to to make sure we change the value
  ret = 0;
  
  _cdelc_fcall2(test_func, args, sizeof(args), &ret);
  printf("ret = %d\n", ret);
  
  return 0;
}
