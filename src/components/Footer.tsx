export default function Footer() {
    return (
        <footer className="w-full bg-[#EFEBE4] border-t border-[#DCCEB8] py-8 mt-auto">
            <div className="container mx-auto text-center text-amber-900/60 text-sm">
                <p>© {new Date().getFullYear()} Awesome Adventure Library. All rights reserved.</p>
                <p className="mt-1 text-xs opacity-70">Read, Explore, Discover.</p>
            </div>
        </footer>
    );
}
