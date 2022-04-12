extern "C" int printF(const char *, ...);

int main () {

    char smth[] = "I finally did it!";
    printF ("%b %o %d %x %s %c %% %s %s\n", 8, 8, 8, 8, smth, 65, smth, smth);

    printF ("%b %o %d %x %s %c %% %s %s\n", 8, 8, 8, 8, smth, 65, smth, smth);

    return 0;
}
