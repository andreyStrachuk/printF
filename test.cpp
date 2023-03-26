extern "C" int printF(const char *, ...);

int main () {

    char smth[] = "I finally did it!";
    printF ("%c %s %d is %b, %o and even %x, and I %s %x %d %% %c%b", 'I', "exactly know that", 3802, 3802, 3802, 3802, "love", 3802, 100, 33, 127);

    printF ("%b %o %d %x %s %c %% %s %s\n", 8, 8, 8, 8, smth, 65, smth, smth);

    return 0;
}
