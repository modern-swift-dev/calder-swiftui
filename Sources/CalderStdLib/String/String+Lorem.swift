public extension String {

    /// A large block of standard "Lorem Ipsum" placeholder text.
    static let loremIpsum = """
    Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vivamus nec magna eu nisl dapibus condimentum. Suspendisse non massa placerat felis volutpat congue eget sodales augue. Sed ultricies lectus non mi elementum, et pharetra est aliquet. Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Donec porta turpis quis eros hendrerit tempor. Nunc sed arcu ac nisl maximus aliquam ut id felis. Nulla aliquet libero id fringilla facilisis. Cras ut ex leo. Fusce feugiat fermentum ipsum, eget pharetra nisl luctus a. Nulla at vestibulum arcu, sed fringilla nulla. Mauris consequat dui ac justo tempus interdum. Maecenas nisi enim, suscipit aliquam nisi at, varius accumsan velit.

    Cras molestie metus est, sit amet efficitur diam maximus placerat. Suspendisse convallis vel elit eget egestas. Sed eget sodales ante. Proin cursus tempor bibendum. Sed pulvinar iaculis mauris non aliquam. Donec vel posuere ante. Ut et facilisis nulla. Donec ornare venenatis neque. Nullam in diam eu nisi sodales dignissim eget id nisi. Nulla porttitor purus in semper tempus. Sed nibh justo, consectetur et ultricies at, molestie eget odio. Maecenas fermentum arcu sit amet elementum tempor. Maecenas congue lectus non quam condimentum accumsan. Proin gravida lorem augue, eget fringilla enim lacinia et.

    Suspendisse malesuada lacus vitae massa semper, a volutpat purus euismod. Pellentesque habitant morbi tristique senectus et netus et malesuada fames ac turpis egestas. Ut vel diam non est tempor congue. Nam quis metus tempor, vestibulum lacus ut, tincidunt turpis. Phasellus vel quam massa. Curabitur pellentesque lectus non elit scelerisque, sed malesuada sapien consequat. Aliquam non risus vel urna ullamcorper interdum at nec lectus. Donec non lorem eu urna pellentesque consequat. Phasellus metus lorem, convallis eu porta vitae, porttitor vel ligula.

    Integer fermentum nibh eget ipsum aliquam, nec posuere ex fringilla. Donec commodo justo vel turpis porttitor porta sed a dolor. Phasellus ipsum nisl, auctor mattis nunc sit amet, interdum cursus lacus. Pellentesque sit amet mollis dui, at malesuada turpis. Pellentesque accumsan nisl leo, eget auctor ante accumsan sed. Nulla facilisi. Duis in purus nec dui interdum euismod. Aenean magna tortor, pretium sit amet urna ac, fermentum blandit ipsum. Nulla leo lacus, tempor quis fringilla at, pretium in erat. Ut pulvinar porta dapibus. Sed tempus efficitur pretium. Sed et feugiat odio, eget pellentesque justo. Donec fermentum justo eu nulla tempus, ut auctor velit faucibus. Nam ultricies dui arcu, ut euismod purus porttitor sit amet. Vivamus gravida quis ligula non semper. Sed mattis elit id quam imperdiet, volutpat euismod ante dictum.

    Nulla vel ex enim. Lorem ipsum dolor sit amet, consectetur adipiscing elit. Vestibulum lobortis lacus arcu, eget congue lacus tincidunt ac. Vivamus fermentum lectus a mollis congue. Nunc at velit nisl. Vestibulum ac pretium quam, eget iaculis odio. Cras tincidunt tellus purus. Morbi a ex id urna suscipit semper. Aliquam auctor pretium porttitor. Nam tortor diam, blandit eget tellus vitae, dapibus porta ipsum. Praesent fermentum cursus quam eget sodales. Curabitur mollis vestibulum nibh id molestie. Integer ultricies dui sit amet neque vulputate, a eleifend augue hendrerit. Aliquam bibendum tincidunt arcu, eget placerat mi condimentum eget. Mauris neque nibh, dapibus interdum ornare in, tincidunt sit amet turpis. Mauris libero erat, eleifend eget neque ac, congue semper enim.
    """

    /// Returns a substring of `loremIpsum` with the specified length.
    /// - Parameter length: The desired length of the lorem ipsum string.
    /// - Returns: A string containing lorem ipsum text up to the specified length.
    static func lorem(_ length: Int) -> String {
        guard length > 0 else {
            return ""
        }
        guard length < loremIpsum.count else {
            return loremIpsum
        }
        let substring = loremIpsum[loremIpsum.startIndex ..< loremIpsum.index(loremIpsum.startIndex, offsetBy: length)]
        return String(substring)
    }
}
