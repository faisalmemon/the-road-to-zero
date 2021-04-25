//
//  kernel_private_headers.h
//  exception-ports
//
//  Created by Faisal Memon on 24/04/2021.
//

#ifndef kernel_private_headers_h
#define kernel_private_headers_h

#import <mach/mach.h>

extern boolean_t exc_server(mach_msg_header_t *InHeadP, mach_msg_header_t *OutHeadP);




#endif /* kernel_private_headers_h */
